# PSColorizer

[![Logo](logo.png)][repo]

> Makes your console output finally look good

## Installation

`Install-Module PSColorizer`

## Usage

### Import module

```ps1
using module PSColorizer
# OR
Import-Module PSColorizer
```

### Write into console

> Write-Colorized is the comandlet exported from this module. It outputs messages using Console.WriteLine method, using certain grammar to format these messages.

Colors are set using the `<color>message</color>` notation.

_Let's imagine you want message to appear violet in user's console:_

`<magenta>Hello world!</magenta>`

![readme-example-1](https://i.imgur.com/zVfWLmu.png)

You can use any string which can be converted to the type `System.ConsoleColor`. Wrong color name will throw an error:

![readme-example-2](https://i.imgur.com/xTEfEiR.png)

Since module uses single regular expression to extract color tags, without any sort of actual parsing, nested color tags are not supported:

![readme-example-3](https://i.imgur.com/ktZoKU9.png)

You can specify default color which will be used outside of color tags:

![readme-example-4](https://i.imgur.com/V6mPNZs.png)

[repo]: https://github.com/2chevskii/PSColorizer
