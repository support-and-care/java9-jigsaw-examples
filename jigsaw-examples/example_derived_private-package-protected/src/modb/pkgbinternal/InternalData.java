package pkgbinternal;

import pkgb.Data;
import pkgbcommon.IdGen;

public class InternalData extends Data {
    private String id;

    public InternalData() {
        id = IdGen.createID();
    }

    @Override
    public String getName() {
        return "is InternalData";
    }

    @Override
    public String toString() {
        return this.getClass().getName() + ", id=" + id;
    }
}
