package pkgzreversebottominternal;

import java.lang.StackWalker.StackFrame;
import java.util.Optional;

public class IdGen {
	public static String createID() {
		// Use call site (filename:line) for deterministic ID generation
		// This ensures the ID is based on where createID() is called from
		Optional<StackFrame> caller = StackWalker.getInstance()
			.walk(frames -> frames
				.skip(2) // Skip the createID() method itself as well as the constructor that called it
				.findFirst()
			);

		if (caller.isPresent()) {
			StackFrame frame = caller.get();
			String fileName = frame.getFileName();
			int lineNumber = frame.getLineNumber();
			// Format: "ID_FileName_Line"
			return String.format("ID_%s_%d",
				fileName.replace(".java", ""),
				lineNumber);
		}

		// Fallback (should never happen)
		return "ID_UNKNOWN";
	}
}
