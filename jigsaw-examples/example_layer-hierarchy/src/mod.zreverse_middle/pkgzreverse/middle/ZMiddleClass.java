package pkgzreverse.middle;

import java.lang.ModuleLayer;
import java.lang.Module;
import java.util.stream.Collectors;

import pkglayer.LayerHierarchy;

public class ZMiddleClass {
    public String doIt() {
        ModuleLayer myLayer = this.getClass().getModule().getLayer();
        String layerName  = LayerHierarchy.getLayerName(myLayer);
        String layerLevel = LayerHierarchy.getLayerLevel(myLayer);

        return "\t" + this.toString() + " [ " + ZMiddleClass.class
            + ", module " + this.getClass().getModule().getName()
            + ", layer '" + layerName + "' on level '" + layerLevel + "' (" + sortedModuleListAsString(myLayer) + ") ]"

            + "\n\tplus " + new pkgzreverse.bottom.ZBottomClass().doIt();
    }

    private static String sortedModuleListAsString(ModuleLayer moduleLayer) {
        return moduleLayer.modules().stream()
                .map(Module::getName)
                .sorted()
                .collect(Collectors.joining(", "));
    }

    @Override
    public String toString() {
        return getClass().getName();
    }
}
