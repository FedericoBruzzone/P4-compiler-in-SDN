#import "@preview/polylux:0.3.1": *
#import themes.simple: *

#import "@preview/hidden-bib:0.1.0": hidden-bibliography

/*
Links:
  - http://wpage.unina.it/rcanonic/didattica/dcn/lucidi/DCN-L08-L09-OpenFlow.pdf
*/

#let background = silver
#let foreground = navy
#let link-background = eastern

#show: simple-theme.with(
    aspect-ratio: "16-9",
    footer: [Adapt Lab -- Università degli Studi di Milan],
    background: background,
    foreground: foreground,
)

#let tiny-size = 0.4em
#let small-size = 0.7em
#let normal-size = 1em
#let large-size = 1.3em
#let huge-size = 1.6em

// #set text(font: "Fira Mono")

#show link: this => {
    let show-type = "underline"
    let label-color = foreground // A label is something like: <a> or #label("a")
    let default-color = link-background

    if show-type == "box" {
      if type(this.dest) == label {
        // Make the box bound the entire text:
        set text(bottom-edge: "bounds", top-edge: "bounds")
        box(this, stroke: label-color + 1pt)
      } else {
        set text(bottom-edge: "bounds", top-edge: "bounds")
        box(this, stroke: default-color + 1pt)
      }
    } else if show-type == "filled" {
      if type(this.dest) == label {
        text(this, fill: label-color)
      } else {
        text(this, fill: default-color)
      }
    } else if show-type == "underline" {
      if type(this.dest) == label {
          let this = text(this, fill: label-color)
          underline(this, stroke: label-color)
      } else {
          let this = text(this, fill: default-color)
          underline(this, stroke: default-color)
      }
    }
    else {
      this
    }
}

#title-slide[
  = P4 Compiler in SDN // P4: programming protocol-independent packet processors
  #v(2em)

  Federico Bruzzone#footnote[
      ADAPT Lab -- Università degli Studi di Milano, \
      #h(1.5em) Website: #link("https://federicobruzzone.github.io/")[federicobruzzone.github.io], \
      #h(1.5em) Github: #link("https://github.com/FedericoBruzzone")[github.com/FedericoBruzzone], \
      #h(1.5em) Email: #link("mailto:federico.bruzzone@unimi.it")[federico.bruzzone\@unimi.it]
  ], PhD Student

  Milan, Italy -- #datetime.today().display("[day] [month repr:long] [year repr:full]")

  #text(tiny-size)[Slides available at:]
  #text(tiny-size)[#link("https://federicobruzzone.github.io/activities/presentations/p4-compiler-in-SDN.pdf")[federicobruzzone.github.io/activities/presentations/p4-compiler-in-SDN.pdf]]
]

#centered-slide[
    = Network Programmability

    #v(2em)

    The ability of the software or the hardware to extecute an externally defined processing algorithm @hauser2023survey

]


#slide[
  == Open Networking Foundation (ONF)

  #one-by-one(start: 1, mode: "transparent")[
      - Non-profit consortium founded in 2011
        #v(3em)
  ][
      - Promotes networking through *Software Defined Networking* (SDN)
        #v(3em)
  ][
      - Standardizes the *OpenFlow* protocol
  ]
]

#slide[
  == Software Defined Networking (SDN)

  #side-by-side[
      #one-by-one(start: 1, mode: "transparent")[
          - Born to overcome the limitations of traditional network architectures

      ][
          - Decouples the control plane from the data plane

      ][
          - Centralizes the control of the network

      ]
  ][
      #image("images/1t.png", width: 70%)
      #image("images/2t.png", width: 70%)
  ]
]

#slide[
    == OpenFlow Protocol

    #one-by-one(start: 1, mode: "transparent")[
        - Gives access to the *forwarding plane* (data plane) of a network device #v(1em)
    ][
        - Mainly used by switches and controllers #v(1em)
    ][
        - Layered on top of the *Transport Control Protocol* (TCP) #v(1em)
    ][
        - De-facto standard for SDN
    ]
]

#slide[
    == OpenFlow Development

    - First appeared in 2008 at @mckeown2008openflow

    - In 2012, Google deploys OpenFlow in its internal network with significant improvements (Urs Hölzle promotes it#footnote[Inter-Datacenter WAN with centralized TE using SDN and OpenFlow])

]


#focus-slide(background: foreground, foreground: background)[
  _Focus!_

  This is very important.
]

#centered-slide[
  = Let's start a new section!
]

#slide[
  == Dynamic slide
  Did you know that...

  #pause
  ...you can see the current section at the top of the slide?
]

#slide[
  = Test

  Did you know that...

  #pause
  ...you can see the current section at the top of the slide?
]

#slide[
  == Dynamic slide
  Did you know that...

  #pause
  ...you can see the current section at the top of the slide?
]

#hidden-bibliography(
    bibliography("local.bib")
)
