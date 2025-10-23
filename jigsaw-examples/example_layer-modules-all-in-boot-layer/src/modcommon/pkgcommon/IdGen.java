package pkgcommon;

import java.util.UUID;

public class IdGen {
	private static int counter = 0;

	public static String createID() {
		// Use deterministic ID for reproducible test results
		// Format: "DETERMINISTIC_ID_" + counter
		counter++;
		return String.format("DETERMINISTIC_ID_%02d", counter);
	}
}
