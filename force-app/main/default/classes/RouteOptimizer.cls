public with sharing class RouteOptimizer {
    public class RouteStop {
        @AuraEnabled public String address;
        @AuraEnabled public Integer order;
        @AuraEnabled public String scheduleId;

        public RouteStop(String address, Integer order, String scheduleId) {
            this.address = address;
            this.order = order;
            this.scheduleId = scheduleId;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<RouteStop> optimizeRoutes(List<String> addresses) {
        if (addresses == null) {
            return new List<RouteStop>();
        }
        List<String> input = new List<String>();
        for (String a : addresses) {
            if (String.isBlank(a)) continue;
            input.add(a.trim());
        }
        if (input.isEmpty()) {
            return new List<RouteStop>();
        }

        // Mock greedy nearest neighbor using string hash distance
        List<String> remaining = new List<String>();
        remaining.addAll(input);
        String current = remaining.remove(0);
        List<String> ordered = new List<String>();
        ordered.add(current);
        while (!remaining.isEmpty()) {
            Integer bestIdx = 0;
            Integer bestDist = Integer.valueOf(2147483647);
            for (Integer i = 0; i < remaining.size(); i++) {
                Integer d = mathAbs(hash(current) - hash(remaining[i]));
                if (d < bestDist) {
                    bestDist = d;
                    bestIdx = i;
                }
            }
            current = remaining.remove(bestIdx);
            ordered.add(current);
        }

        List<RouteStop> result = new List<RouteStop>();
        Integer ord = 1;
        for (String s : ordered) {
            result.add(new RouteStop(s, ord, null));
            ord++;
        }
        return result;
    }

    @InvocableMethod(label='Optimize Routes from Addresses' description='Returns mock optimized route order')
    public static List<String> optimizeRoutesInvocable(List<String> addresses) {
        List<RouteStop> stops = optimizeRoutes(addresses);
        List<String> out = new List<String>();
        for (RouteStop s : stops) out.add(s.address);
        return out;
    }

    private static Integer hash(String s) {
        Integer h = 0;
        for (Integer i = 0; i < s.length(); i++) {
            h = 31 * h + s.substring(i, i+1).hashCode();
        }
        if (h < 0) h = -h;
        return h;
    }

    private static Integer mathAbs(Integer v) {
        return v < 0 ? -v : v;
    }
}