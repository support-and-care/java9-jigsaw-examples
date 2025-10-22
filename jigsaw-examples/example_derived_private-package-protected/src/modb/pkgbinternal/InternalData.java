package pkgbinternal;

import pkgb.Data;

public class InternalData extends Data {
    @Override
    public String getName() {
        return "is InternalData";
    }

    @Override
    public String toString() {
        return getClass().getName();
    }
}
