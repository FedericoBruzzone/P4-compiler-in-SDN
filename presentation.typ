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
#let problem-background = rgb(255, 204, 0)

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
// #show raw: it => block(
//   inset: 8pt,
//   text(fill: foreground, font: "Fira Mono", it)
//   radius: 5pt,
//   fill: rgb("#1d2433"),
// )

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

  #v(2em)

  - Non-profit consortium founded in 2011 #v(1em)

  - Promotes networking through *Software Defined Networking* (SDN) #v(1em)

  - Standardizes the *OpenFlow* protocol
]

#slide[
  == Software Defined Networking (SDN)

  #side-by-side[
      - Born to overcome the limitations of traditional network architectures

      - Decouples the control plane from the data plane

      - Centralizes the control of the network
  ][
      #image("images/1t.png", width: 70%)
      #image("images/2t.png", width: 70%)
  ]
]

#slide[
    == OpenFlow Protocol

    - Gives access to the *forwarding plane* (data plane) of a network device #v(1em)
    - Mainly used by switches and controllers #v(1em)
    - Layered on top of the *Transport Control Protocol* (TCP) #v(1em)
    - De-facto standard for SDN
]

#slide[
    == OpenFlow Development

    - First appeared in 2008 @mckeown2008openflow #v(1em)
    - In April 2012, Google deploys OpenFlow in its internal network with significant improvements (Urs Hölzle promotes it#footnote[Inter-Datacenter WAN with centralized TE using SDN and OpenFlow.]) #v(1em)
    - In January 2013, NEC rolls out OpenFlow for Microsoft Hyper-V #v(1em)
    - Latest version is 1.5.1 (Apr 2015)
]

#slide[
  = Fields in OpenFlow Standard

  #v(2em)

  #table(
      columns: (1fr, 1fr, auto),
      table.header(
          "Version",
          "Date",
          "Header Fields"
      ),
      "OF 1.0",
      "Dec 2009",
      "12 fields (Ethernet, TCP/IPv4)",
      "OF 1.1",
      "Feb 2011",
      "15 fields (MPLS, inter-table metadata)",
      "OF 1.2",
      "Dec 2011",
      "36 fields (APR, ICMP, IPv6, etc.)",
      "OF 1.3",
      "Jun 2012",
      "40 fields",
      "OF 1.4",
      "Oct 2013",
      "41 fields",
  )

  More Details on the OpenFlow v1.0.0 Switch Specification #footnote[
      https://opennetworking.org/wp-content/uploads/2013/04/openflow-spec-v1.0.0.pdf
  ]
]

// #focus-slide(background: problem-background, foreground: foreground)[
#focus-slide(background: foreground, foreground: background)[
    == OpenFlow is protocol-dependent

    #text(small-size)[Fixed set of fields and parser based on standard protocols]

    #text(tiny-size)[(Ethernet, IPv4/IPv6, TCP/UDP)]

    // #text(small-size)[Assumes that the match+action table are in series]
]

#centered-slide[
    = P4: #underline[P]rogramming #underline[P]rotocol-Independent #underline[P]acket #underline[P]rocessors

    #v(2em)

    Bosshart believed that future generations of OpenFlow would have allowed the controller to _tell the switch how to operate_ @bosshart2014p4
]

#slide[
  == Goals and Challenges

  #one-by-one(start: 1, mode: "transparent")[
      *Reconfigurability*: the controller should be able to redefine the packet parsing and processing in the field

  ][
      *Protocol Independence*: the switch should _headers_ using parsing and processing using _match+action_ tables

    ][
        *Target Independence*: a compiler from _target-independent_ description to _target-dependent_ binary
    ]
]

#slide[
  == Abstract Forwarding Model (AFM)

  #side-by-side[
      #one-by-one(start: 1, mode: "transparent")[
          #text(small-size)[1. Parsing the packet headers]

      ][
          #text(small-size)[
          2. The fields are passed to the match-action pipeline.
              - *Ingrees*: determines the egress port/queue
              - *Egress*: per-instance header modifications
          ]

      ][
          #text(small-size)[3. Metadata processing (e.g., timestamp)]
      ][
          #text(small-size)[4. As in OpenFlow, the queuing discipline is chosen at switch configuration time (e.g., minimum rate)]
      ]
  ][
      #image("images/3t.png")
  ]
]

#slide[
    == Two-stage Compilation
    #align(center)[Imperative control flow program based on *AFM*] #v(1em)
    #side-by-side[
        1. The compiler translate the P4 program into *TDGs* #text(tiny-size)[(Table Dependency Graphs)] #v(1em)

        2. The *TDGs* are compiled into *target-dependent* code
    ][
        #image("images/4t.png")
    ]
]

#focus-slide(background: foreground, foreground: background)[
    = Language Design
     #text(tiny-size)[Header: Describes the structure of a series of fields including the widths and constraints on values]

    #text(tiny-size)[Parser: Specifies how to identify headers and valid header sequences within packets]

    #text(tiny-size)[Tables: The P4 program defines the fields on which a table may match and the actions it may execute]

    #text(tiny-size)[Actions: P4 supports construction of complex actions from simpler protocol-independent primitives. These complex actions are available within match+action]

    #text(tiny-size)[Control Programs: The control program determines the order of match+action tables that are applied to a packet. A simple imperative program describe the flow of control between match+action]
]


#slide[
    == Header
    #side-by-side[
        #raw(
"header ethernet {
  fields {
    dst_addr: 48; // bits
    src_addr: 48;
    ethertype: 16;
  }
}", lang: "c++")
    ][
        #raw(
"header vlan {
  fields {
    pcp: 3;
    cfi: 1;
    vid: 12;
    ethertype: 16;
  }
}", lang: "c++")
    ]
]

#slide[
    == Parser
]

#slide[
    == Tables
    #text(small-size)[]
]

#slide[
    == Actions
    #text(small-size)[Define the operations that can be performed on the packet]
]

#slide[
    == Control Programs
    #text(small-size)[Define the control flow of the packet processing pipeline]
]

#hidden-bibliography(
    bibliography("local.bib")
)


// Example Transparent
// #slide[
//   == Open Networking Foundation (ONF)
//   #one-by-one(start: 1, mode: "transparent")[
//       - Test
//         #v(3em)
//   ][
//       - Test
//         #v(3em)
//   ][
//       - Test
//   ]
// ]
