Pod::Spec.new do |spec|
  spec.name = "CoreDataImportKit"
  spec.version = "0.1.0"
  spec.summary = "Swift framework for importing data into CoreData."
  spec.homepage = "https://github.com/orangeqc/CoreDataImportKit"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Ryan Mathews" => 'ryan@ryanjm.com' }
  spec.platform = :ios, "8.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/orangeqc/CoreDataImportKit.git", tag: spec.version.to_s }
  spec.source_files = "CoreDataImportKit/**/*.{h,swift}"
end
