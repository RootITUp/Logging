In this minor release we fixed an annoying issue about how the module loads the available targets.
Now the loading routine is run inside the runspace to isolate the scope where the targets scriptblock is created.

- [BUG] Major code update to address issue #63
- [FIX] `Set-LoggingDefaultLevel` sets default level on cofigured targets too (#61, #58)
- [MOD] Removed validation on parameter Arguments
