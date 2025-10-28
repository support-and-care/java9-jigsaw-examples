package pkgc;

import pkgcinternal.IdGen;

public class C {
    private String id;

    public C() {
        id = IdGen.createID();
    }

    public String doIt() {
        return "from C";
    }

    @Override
    public String toString() {
        return this.getClass().getName() + ", id=" + id;
    }
}
