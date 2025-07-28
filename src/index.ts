{
  "name": "frankenphp",
  "compatibility_date": "2024-06-01",
  "main": "src/index.ts",
  "compatibility_flags": ["nodejs_compat"],
  "durable_objects": {
    "bindings": [
      {
@@ -19,10 +12,16 @@
      }
    ]
  },
  "migrations": [
    {
      "tag": "v1",
      "new_classes": ["MyContainer"]
    }
  ],
  // 删除 upload
  // "build": {
  //   "upload": { ... } ❌ 不要这个
  // }
}
