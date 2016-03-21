# CoreDataImportKit

CoreDataImportKit (CDI) is a no frills, 100% Swift, CoreData importer. Easily define your mappings (i.e. how json data relates to your CoreData attributes) within your CoreData file (`*.xcdatamodeld`). No extra code needed.

There are no additional CoreData helpers. If you need that, check out [MagicalRecord](https://github.com/magicalpanda/MagicalRecord). 

The goal of CDI is to stay super lean and easy to maintain. CDI plans on being the _best_ framework written in Swift for implementing importing in your projects.

## Installation

It is recommended to add to your project via [CocoaPods](https://cocoapods.org/). Just add the following to your Podfile:

```txt
use_frameworks!

target `YourProject` do
    pod 'CoreDataImportKit'
end
```

## Usage

In order to run an import, you need two things: a mapping and an importer. Once you’ve set that up, you just need to call `importRepresentation()` to import everything. Here is how you do it in Swift:

```swift
let mapping = CDIMapping(entityName: "Company", inManagedObjectContext: localContext)
let cdiImport = CDIImport(externalRepresentation: companyArray, mapping: mapping, context: localContext)
cdiImport.importRepresentation()
```

That’s it.

> Coming soon: I’ll be adding a shortcut to do the above in one line.

Check out the wiki (soon) to learn more about the importer and how you can create your own import strategy based on your needs.

## Contributing

Think you have a way of making the importer faster? Have a way of making the code easier to understand? Want to help out with the [ROADMAP](ROADMAP.md)? Please consider making a pull request.

If you want to discuss changes before writing the code, go ahead and create a Github issue to discuss the potential change. Changes are welcome, just make sure it is tested and that all existing tests continue to pass.

## Extra

CoreDataImportKit was written by Ryan Mathews, you can follow me on [twitter](https://twitter.com/ryanjm33).