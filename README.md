# Fork
This is a fork of `packwerk` meant to explore using a Rust core for parsing.

Right now I'm mostly focused on getting things hooked up before optimizing the performance, but this should already be slightly faster than Shopify/packwerk.

# Benchmarking
I ran `bin/packwerk check` 5 times before and after:

## Cold Cache
```
DISABLE_SPRING=1 RUST_LOG=debug rm -rf tmp/cache/packwerk && time bin/packwerk check
```

# Before
```
real	1m40.659s
real	1m39.591s
real	1m43.295s
real	1m39.311s
real	2m5.006s
```

# After
```
real	1m21.554s
real	1m0.891s
real	1m11.676s
real	1m19.408s
real	1m3.268s
```

## Hot Cache
```
DISABLE_SPRING=1 RUST_LOG=debug time bin/packwerk check
```

# Before
```
TODO
```

# After
```
TODO
```
