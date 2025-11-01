package pkgu;

import java.lang.ModuleLayer;
import java.lang.Module;
import java.util.stream.Collectors;

import pkglayer.LayerHierarchy;
import pkguinternal.IdGen;

public class U {
    private String id;

    public U() {
        id = IdGen.createID();
    }

    public String doIt() {
        ModuleLayer myLayer = this.getClass().getModule().getLayer();
        String layerName  = LayerHierarchy.getLayerName(myLayer);
        String layerLevel = LayerHierarchy.getLayerLevel(myLayer);

        return "\t" + this.toString() + " [ " + U.class
            + ", module " + this.getClass().getModule().getName()
            + ", layer " + layerName + " on level " + layerLevel + " (" + sortedModuleListAsString(myLayer) + ") ]";
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
