package pkgy.middle;

import java.lang.ModuleLayer;
import java.lang.Module;
import java.util.stream.Collectors;

import pkglayer.LayerHierarchy;
import pkgymiddleinternal.IdGen;

public class YMiddleClass extends pkgy.top.YTopClass {
    private String id;

    public YMiddleClass() {
        id = IdGen.createID();
    }

    @Override
    public String doIt() {
        ModuleLayer myLayer = this.getClass().getModule().getLayer();
        String layerName  = LayerHierarchy.getLayerName(myLayer);
        String layerLevel = LayerHierarchy.getLayerLevel(myLayer);

        return "\t" + this.toString() + " [ " + YMiddleClass.class
            + ", module " + this.getClass().getModule().getName()
            + ", layer '" + layerName + "' on level '" + layerLevel + "' (" + sortedModuleListAsString(myLayer) + ") ]"

            + "\n\tplus " + super.doIt();
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
