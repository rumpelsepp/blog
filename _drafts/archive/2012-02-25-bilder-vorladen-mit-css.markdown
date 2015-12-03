---
layout: post
title: Bilder vorladen mit CSS
date: '2012-02-25 11:12:05 +0100'
tags:
- scripting
---
Wenn man ausgiebigen Gebrauch von der CSS Pseudoklasse `:hover` macht, um damit
z.B. Mouseovereffekte bei Buttons (-> kleine Bilder) zu realisieren, taucht ein
kleiner Schönheitsfehler auf. Beim ersten Mouseover müssen die -- noch nicht
gecachten -- `:hover` Bilder nachgeladen werden. Dadurch entsteht eine kleine
Verzögerung, die nicht unbedingt erwünscht ist.

Zur Lösung des Problems lädt man die Bilder gleich zu Beginn. Damit das Layout
dann allerdings nicht komisch aussieht versteckt man sie per CSS Anweisung.

```html
<!-- ... -->

<!-- Navigation -->
<a href="ziel1"><img src="bild1.png" width="x" height="y"/></a>
<a href="ziel2"><img src="bild2.png" width="x" height="y"/></a>
<a href="ziel3"><img src="bild3.png" width="x" height="y"/></a>

<!-- Mouseover *.pngs -->
<img class="hideme" src="bild1hover.png"/>
<img class="hideme" src="bild2hover.png"/>
<img class="hideme" src="bild3hover.png"/>

<!-- ... -->
```

Die Klasse `hideme` muss noch in einem CSS File definiert werden:

```css
.hideme {
    width: 0px;
    height: 0px;
    visibility: hidden;
}
```

Durch die Größenangeben von jeweils 0px wird das Layout nicht verändert. Die
Anweisung `visibility: hidden;` versteckt das Bild. Jetzt stehen die Hover
Dateien bereits vor dem ersten Mouseover zur Verfügung und das Menü; erweckt
einen viel flüssigeren Eindruck.
