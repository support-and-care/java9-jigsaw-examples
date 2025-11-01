package pkgbinternal;

import pkgbcommon.IdGen;

public class BFromModuleButInternal {
    private String id;

    public BFromModuleButInternal() {
        id = IdGen.createID();
    }

    public String doIt(String input) {
        return "from pkgbinternal.BFromModuleButInternal, " + input;
    }

    @Override
    public String toString() {
        return this.getClass().getName() + ", id=" + id;
    }
}
