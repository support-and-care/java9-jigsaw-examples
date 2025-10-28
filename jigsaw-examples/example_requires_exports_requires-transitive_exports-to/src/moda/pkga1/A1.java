package pkga1;

import pkgb.B;
import pkgc.C;
import pkgainternal.IdGen;

public class A1 {
    private String id;

    public A1() {
        id = IdGen.createID();
    }

    public String doIt() {
        return "from A1, " + new B().doIt();
    }

    public C getMyC() {
        return new C();
    }

    @Override
    public String toString() {
        return this.getClass().getName() + ", id=" + id;
    }
}
