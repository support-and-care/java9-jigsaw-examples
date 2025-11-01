package pkga2;

import pkgainternal.InternalA;
import pkgainternal.IdGen;

public class A2 {
    private String id;

    public A2() {
        id = IdGen.createID();
    }

    public String doIt() {
        return "from A2 (plus: " + new InternalA().doIt() + ")";
    }

    @Override
    public String toString() {
        return this.getClass().getName() + ", id=" + id;
    }
}
