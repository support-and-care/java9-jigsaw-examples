package pkgy.top;

import java.lang.ModuleLayer;
import java.lang.Module;
import java.util.stream.Collectors;

import pkglayer.LayerHierarchy;
import pkgytopinternal.IdGen;

public class YTopClass {
    private String id;

    public YTopClass() {
        id = IdGen.createID();
    }

    public String doIt() {
        ModuleLayer myLayer = this.getClass().getModule().getLayer();
        String layerName  = LayerHierarchy.getLayerName(myLayer);
        String layerLevel = LayerHierarchy.getLayerLevel(myLayer);

        return "\t" + this.toString() + " [ " + YTopClass.class
            + ", module " + this.getClass().getModule().getName()
            + ", layer '" + layerName + "' on level '" + layerLevel + "' (" + sortedModuleListAsString(myLayer) + ") ]";
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
