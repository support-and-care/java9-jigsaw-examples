package pkgcpmain;

import java.lang.reflect.Constructor;

/**
 * This class is on the classpath, i.e. in the unnamed module.
 */
public class MainCallingModB {
    public static void main(String[] args) throws Exception    {
    	try {
    		Class<?> clazz = Class.forName("pkgb.BFromModule");		// from module modb , package pkgb is exported
	        Constructor<?> con = clazz.getDeclaredConstructor();
	        con.setAccessible(true);
	        Object o = con.newInstance();
	        System.out.println(o.toString());
    	}
    	catch (Throwable t) {
            System.out.println("Caught exception: " + t.getClass());
            System.exit(1);
    	}

    	try {
	        Class<?> clazz = Class.forName("pkgbinternal.BFromModuleButInternal");		// from module modb , package pkgbinternal is not exported
	        Constructor<?> con = clazz.getDeclaredConstructor();
	        con.setAccessible(true);
	        Object o = con.newInstance();
	        System.out.println(o.toString());
    	}
    	catch (Throwable t) {
            System.out.println("Caught exception: " + t.getClass());
            System.exit(1);
    	}

    	try {
	        Class<?> clazz = Class.forName("pkgbexportedqualified.BFromModuleButExportedQualified");		// from module modb , package pkgbexportedqualified is exported but only qualified for modc
	        Constructor<?> con = clazz.getDeclaredConstructor();
	        con.setAccessible(true);
	        Object o = con.newInstance();
	        System.out.println(o.toString());
    	}
    	catch (Throwable t) {
            System.out.println("Caught exception: " + t.getClass());
            System.exit(1);
    	}
    }
}
