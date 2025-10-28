package pkgcpmain;

import java.lang.reflect.Constructor;

/**
 * This class is on the classpath, i.e. in the unnamed module.
 */
public class MainCallingJavaBaseSunNet {
    public static void main(String[] args) throws Exception {
    	try {
	        Class<?> clazz = Class.forName("sun.net.PortConfig");				// from module java.base, but other package than jdk.internal.*
	        Constructor<?> con = clazz.getDeclaredConstructor();
	        con.setAccessible(true);
	        Object o = con.newInstance();
	        System.out.println(o.getClass().getName());
    	}
    	catch (Throwable t) {
            System.out.println("Caught exception: " + t.getClass());
            System.exit(1);
    	}
    }
}
