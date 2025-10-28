package pkgb;

import pkgbcommon.IdGen;

public class BFromModule {
    private String id;

    public BFromModule() {
        id = IdGen.createID();
    }

    public String doIt(String input) {
        return "from pkgb.BFromModule, " + input;
    }

    @Override
    public String toString() {
        return this.getClass().getName() + ", id=" + id;
    }
}
