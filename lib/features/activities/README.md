# Activities feature

Owns the activity model, repository contract, and storage implementation. Each
saved record includes its name and a stable icon ID from the searchable,
categorized monochrome icon catalog. The repository stores the activity list
and selected list index. Existing single-activity preferences remain readable;
records without an icon load with the default sparkle icon.
