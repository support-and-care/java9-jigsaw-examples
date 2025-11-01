package pkgbexportedqualified;

import pkgbcommon.IdGen;

public class BFromModuleButExportedQualified {
    private String id;

    public BFromModuleButExportedQualified() {
        id = IdGen.createID();
    }

    public String doIt(String input) {
        return "from pkgbexportedqualified.BFromModuleButExportedQualified, " + input;
    }

    @Override
    public String toString() {
        return this.getClass().getName() + ", id=" + id;
    }
}
