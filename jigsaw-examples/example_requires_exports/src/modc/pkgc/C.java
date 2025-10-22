package pkgc;

public class C {
    public String doIt() {
        return "from C";
    }

    @Override
    public String toString() {
        return getClass().getName();
    }
}
