{
  minMemory,
  maxMemory,
}:

# https://github.com/Mukul1127/Minecraft-Performance-Flags-Benchmarks
builtins.concatStringsSep " " [
  "-Xms${minMemory}"
  "-Xmx${maxMemory}"

  # basic
  "-XX:+UnlockExperimentalVMOptions"
  "-XX:+UnlockDiagnosticVMOptions"
  "-XX:+AlwaysActAsServerClassMachine"
  "-XX:+AlwaysPreTouch"
  "-XX:+DisableExplicitGC"
  "-XX:NmethodSweepActivity=1"
  "-XX:ReservedCodeCacheSize=400M"
  "-XX:NonNMethodCodeHeapSize=12M"
  "-XX:ProfiledCodeHeapSize=194M"
  "-XX:NonProfiledCodeHeapSize=194M"
  "-XX:-DontCompileHugeMethods"
  "-XX:MaxNodeLimit=240000"
  "-XX:NodeLimitFudgeFactor=8000"
  "-XX:+UseVectorCmov"
  "-XX:+PerfDisableSharedMem"
  "-XX:+UseFastUnorderedTimeStamps"
  "-XX:+UseCriticalJavaThreadPriority"
  "-XX:ThreadPriorityPolicy=1"
  "-XX:AllocatePrefetchStyle=3"

  # server G1GC
  "-XX:+UseG1GC"
  "-XX:MaxGCPauseMillis=130"
  "-XX:+UnlockExperimentalVMOptions"
  "-XX:+DisableExplicitGC"
  "-XX:+AlwaysPreTouch"
  "-XX:G1NewSizePercent=28"
  "-XX:G1HeapRegionSize=16M"
  "-XX:G1ReservePercent=20"
  "-XX:G1MixedGCCountTarget=3"
  "-XX:InitiatingHeapOccupancyPercent=10"
  "-XX:G1MixedGCLiveThresholdPercent=90"
  "-XX:G1RSetUpdatingPauseTimePercent=0"
  "-XX:SurvivorRatio=32"
  "-XX:MaxTenuringThreshold=1"
  "-XX:G1SATBBufferEnqueueingThresholdPercent=30"
  "-XX:G1ConcMarkStepDurationMillis=5"
  "-XX:G1ConcRefinementServiceIntervalMillis=150"
  "-XX:G1ConcRSHotCardLimit=16"

  # GraalVM java
  # "-XX:+UnlockExperimentalVMOptions"
  # "-XX:+UnlockDiagnosticVMOptions"
  # "-XX:+AlwaysActAsServerClassMachine"
  # "-XX:+AlwaysPreTouch"
  # "-XX:+DisableExplicitGC"
  # "-XX:AllocatePrefetchStyle=3"
  # "-XX:NmethodSweepActivity=1"
  # "-XX:ReservedCodeCacheSize=400M"
  # "-XX:NonNMethodCodeHeapSize=12M"
  # "-XX:ProfiledCodeHeapSize=194M"
  # "-XX:NonProfiledCodeHeapSize=194M"
  # "-XX:-DontCompileHugeMethods"
  # "-XX:+PerfDisableSharedMem"
  # "-XX:+UseFastUnorderedTimeStamps"
  # "-XX:+UseCriticalJavaThreadPriority"
  # "-XX:+EagerJVMCI"
  # "-Dgraal.TuneInlinerExploration=1"
]
