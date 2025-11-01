package pkgmainbar;

import pkgmainbarinternal.IdGen;

public class Main {
    private String id;

    public Main() {
        id = IdGen.createID();
    }

    public static void main(String[] args) {
        Main mymain = new Main();
        System.out.println("Main: " + mymain.toString());
    }

    @Override
    public String toString() {
        return this.getClass().getName() + ", id=" + id;
    }
}
