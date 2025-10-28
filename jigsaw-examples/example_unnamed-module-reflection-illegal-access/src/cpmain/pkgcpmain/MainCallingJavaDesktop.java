package pkgcpmain;

import java.lang.reflect.Constructor;

/**
 * This class is on the classpath, i.e. in the unnamed module.
 */
public class MainCallingJavaDesktop {
	public static void main(String[] args) throws Exception {
		try {
			Class<?> clazz = Class.forName("sun.awt.OSInfo"); // from module java.desktop
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
