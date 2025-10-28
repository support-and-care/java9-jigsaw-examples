package pkgz.bottom;

import java.lang.ModuleLayer;
import java.lang.Module;
import java.util.stream.Collectors;

import pkglayer.LayerHierarchy;
import pkgzbottominternal.IdGen;

public class ZBottomClass {
    private String id;

    public ZBottomClass() {
        id = IdGen.createID();
    }

    public String doIt() {
        ModuleLayer myLayer = this.getClass().getModule().getLayer();
        String layerName  = LayerHierarchy.getLayerName(myLayer);
        String layerLevel = LayerHierarchy.getLayerLevel(myLayer);

        return "\t" + this.toString() + " [ " + ZBottomClass.class
            + ", module " + this.getClass().getModule().getName()
            + ", layer '" + layerName + "' on level '" + layerLevel + "' (" + sortedModuleListAsString(myLayer) + ") ]"

            + "\n\tplus " + new pkgz.middle.ZMiddleClass().doIt();
    }

    private static String sortedModuleListAsString(ModuleLayer moduleLayer) {
        return moduleLayer.modules().stream()
                .map(Module::getName)
                .sorted()
                .collect(Collectors.joining(", "));
    }

    @Override
    public String toString() {
        return this.getClass().getName() + ", id=" + id;
    }
}
