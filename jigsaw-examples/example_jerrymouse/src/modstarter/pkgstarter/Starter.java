package pkgstarter;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.lang.module.Configuration;
import java.lang.module.ModuleFinder;
import java.lang.module.ModuleReference;
import java.lang.reflect.Method;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class Starter {

    private static String relPath(Path base, Path p) {
        try {
            return base.relativize(p.toAbsolutePath().normalize()).toString();
        } catch (Exception ex) {
            return p.toAbsolutePath().normalize().toString();
        }
    }

    private static class TaskOutput {
        final String appName;
        final String stdout;
        final String stderr;
        TaskOutput(String appName, String stdout, String stderr) {
            this.appName = appName;
            this.stdout = stdout != null ? stdout : "";
            this.stderr = stderr != null ? stderr : "";
        }
    }
    public static void main(String[] args) throws Exception {
        if (args.length < 2) {
            System.out.println("Usage: JerryMouse starter <baseDir> <logDir> [--sync]");
            System.exit(1);
        }

        String basedir = args[0];
        String logdir = args[1];
        boolean syncMode = args.length > 2 && args[2].equals("--sync");
        Path basePath = Paths.get(basedir).toAbsolutePath().normalize();
        Path logPath = Paths.get(logdir).toAbsolutePath().normalize();
        if (!Files.exists(logPath)) {
            Files.createDirectories(logPath);
        }
        // $basedir/apps contain the startable applications
        Path appPath = basePath.resolve("apps").normalize();

        System.out.println("[JerryMouse] Scanning for apps in " + relPath(basePath, appPath));

        ExecutorService executor = Executors.newSingleThreadExecutor(); // only one thread as otherwise logging output is cluttered and not sorted
        List<Future<TaskOutput>> runningApps = new ArrayList<Future<TaskOutput>>();
        try {
            List<Path> sortedPaths = new ArrayList<>();
            Files.newDirectoryStream(appPath, file -> Files.isDirectory(file)).forEach(sortedPaths::add);
            sortedPaths.sort((p1, p2) -> p1.getFileName().toString().compareTo(p2.getFileName().toString()));

            try (var stream = sortedPaths.stream()) {
                stream.forEach(path -> {
                    String appName = path.normalize().getFileName().toString();

                    System.out.println("--------------------------------------------------------------------------------------------------------------------");
                    System.out.println("[JerryMouse|" +appName+ "] Initiating layer for application: " + appName);
                    System.out.println("[JerryMouse|" +appName+ "] Loading modules from "+ relPath(basePath, path));

                    // Default: Root Module has the same name as the name of the app directory
                    String rootModuleName = path.getFileName().toString();
                    // Default: names for boot class ...
                    String bootClassName  = "Main";
                    // Default: ... and for boot method
                    String bootMethodName = "main";

                    File appJSONFile = new File(path.toFile(),"app.json");
                    System.out.println("[JerryMouse|" +appName+ "] Loading app description from " + relPath(basePath, appJSONFile.toPath()));
                    try (InputStream in = new FileInputStream(appJSONFile)) {
                        JsonReader reader = Json.createReader(in);
                        JsonObject obj = reader.readObject();
                        rootModuleName = obj.getJsonString("rootModule").getString();
                        bootClassName  = obj.getJsonString("bootClass").getString();
                        bootMethodName = obj.getJsonString("bootMethod").getString();
                    }
                    catch (IOException fex) {
                        System.out.println("[JerryMouse|" +appName+ "] Error: " + relPath(basePath, appJSONFile.toPath()) + " not found for application " + appName + ". Using defaults.");
                        return;
                    }

                    System.out.println("[JerryMouse|" +appName+ "] Root module: " + rootModuleName);
                    System.out.println("[JerryMouse|" +appName+ "] Boot class: "  + bootClassName);
                    System.out.println("[JerryMouse|" +appName+ "] Boot method: " + bootMethodName);

                    ModuleFinder finder = ModuleFinder.of(Paths.get(path.toString(), "mlib") );

                    Optional<ModuleReference> result = finder.find(rootModuleName);
                    if (! result.isPresent()) {
                        System.out.println("[JerryMouse|"+appName+"] Error: Root module " + rootModuleName + " not found.");
                    }
                    else {
                        try {
                            // Create Configuration based on the root module
                            Configuration cf = ModuleLayer.boot().configuration().resolve
                                    (ModuleFinder.of(), finder, Set.of(rootModuleName));

                            // Create new Jigsaw Layer with configuration and ClassLoader
                            ModuleLayer layer = ModuleLayer.boot().defineModulesWithOneLoader(cf, ClassLoader.getSystemClassLoader());

                            System.out.println("[JerryMouse|"+appName+"] Created layer containing the following modules:");
                            layer.modules().stream()
                                    .sorted((m1, m2) -> m1.getName().compareTo(m2.getName()))
                                    .forEach(module -> System.out.println("         " + module.getName()));
                            System.out.flush();

                            try {
                                // run the static method Boot.run() of the root module, done via reflection
                                //   (is executed in an ExecutorTask)
                                Class<?> bootClass  = layer.findLoader(rootModuleName).loadClass(bootClassName);

                                // addReads needed in order to be able to read the module
                                Starter.class.getModule().addReads(bootClass.getModule());
                                
                                // start the application
                                System.out.println("[JerryMouse|"+appName+"] Calling boot method (" + rootModuleName +"/"+ bootClassName 
                                        + "." + bootMethodName +") in " + (syncMode ? "foreground" : "background."));
                                System.out.flush();

                                String[] params = null;
                                Method   bootMethod = bootClass.getMethod(bootMethodName, String[].class);
                                Callable<TaskOutput> task = () -> {
                                    ByteArrayOutputStream outBuf = new ByteArrayOutputStream();
                                    ByteArrayOutputStream errBuf = new ByteArrayOutputStream();
                                    PrintStream prevOut = System.out;
                                    PrintStream prevErr = System.err;
                                    PrintStream tmpOut = new PrintStream(outBuf, true);
                                    PrintStream tmpErr = new PrintStream(errBuf, true);
                                    try {
                                        System.setOut(tmpOut);
                                        System.setErr(tmpErr);
                                        bootMethod.invoke(null, (Object) params);
                                    } catch (Exception ex) {
                                        System.out.println("[JerryMouse|"+appName+"] Error: Caught exception:");
                                        ex.printStackTrace(System.out);
                                    } finally {
                                        try { System.out.flush(); } catch (Exception ignore) {}
                                        try { System.err.flush(); } catch (Exception ignore) {}
                                        System.setOut(prevOut);
                                        System.setErr(prevErr);
                                        try { tmpOut.close(); } catch (Exception ignore) {}
                                        try { tmpErr.close(); } catch (Exception ignore) {}
                                    }
                                    return new TaskOutput(appName, outBuf.toString(), errBuf.toString());
                                };
                                if (syncMode) {
                                    TaskOutput output = task.call();
                                    Path stdoutPath = logPath.resolve(output.appName + ".out");
                                    Path stderrPath = logPath.resolve(output.appName + ".err");
                                    Files.writeString(stdoutPath, output.stdout);
                                    Files.writeString(stderrPath, output.stderr);
                                } else {
                                    runningApps.add(executor.submit(task));
                                }
                            } 
                            catch (ClassNotFoundException ex) {
                                System.out.println("[JerryMouse|"+appName+"] Error: Class " + bootClassName + " not found in default package for root module " + rootModuleName);
                                ex.printStackTrace(System.out);
                            } 
                            catch (NoSuchMethodException ex) {
                                System.out.println("[JerryMouse|"+appName+"] Error: Could not call method " + bootMethodName + " in class " + bootClassName + ".");
                                ex.printStackTrace(System.out);
                            }
                        }
                        catch (Exception ex) {
                            System.out.println("[JerryMouse|"+appName+"] Error: Caught exception:");
                            ex.printStackTrace(System.out);
                        }
                    } 
                });
                
                System.out.flush();
            }

            // wait for all tasks to complete
            int current = 0;
            for (Future<TaskOutput> task: runningApps) {
                TaskOutput output = task.get();

                if (output != null) {
                    System.out.println("********");
                    System.out.println("Waiting for task '" + output.appName + "' (" + current++ + "/" + runningApps.size() + ") to complete...");
                    while (!task.isDone()) {
                        Thread.sleep(1000); // Wait 1 second before checking again
                    }
                    System.out.println("Task completed!");
                }
                System.out.println("Task '" + output.appName + "' is done");

                // Write output to log files
                Path stdoutPath = logPath.resolve(output.appName + ".out");
                Path stderrPath = logPath.resolve(output.appName + ".err");
                Files.writeString(stdoutPath, output.stdout);
                Files.writeString(stderrPath, output.stderr);

                System.out.println("********");
                System.out.flush();
            }
        } 
        finally {
            System.out.println("--------------------------------------------------------------------------------------------------------------------");
            System.out.println("[JerryMouse] All apps completed. Shutting down.");
            executor.shutdown();
        }
    }
}
