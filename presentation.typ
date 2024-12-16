/*
Links:
  - http://wpage.unina.it/rcanonic/didattica/dcn/lucidi/DCN-L08-L09-OpenFlow.pdf
*/

#import "./theme/fcb.typ": *

#let background = silver
#let foreground = navy
#let link-background = eastern

#show: fcb-theme.with(
  aspect-ratio: "16-9",
  footer: [Federico Bruzzone -- Adapt Lab -- Università degli Studi di Milano], background: background,
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

  Federico Bruzzone, #footnote[
      ADAPT Lab -- Università degli Studi di Milano, \
      #h(1.5em) Website: #link("https://federicobruzzone.github.io/")[federicobruzzone.github.io], \
      #h(1.5em) Github: #link("https://github.com/FedericoBruzzone")[github.com/FedericoBruzzone], \
      #h(1.5em) Email: #link("mailto:federico.bruzzone@unimi.it")[federico.bruzzone\@unimi.it]
  ] PhD Student

  Milan, Italy -- #datetime.today().display("[day] [month repr:long] [year repr:full]")

  #text(small-size)[
      Slides available at
      #v(-1em)
      #link("https://federicobruzzone.github.io/activities/presentations/P4-compiler-in-SDN.pdf")[federicobruzzone.github.io/activities/presentations/P4-compiler-in-SDN.pdf]
  ]
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
    - In April 2012, Google deploys OpenFlow in its internal network with significant improvements (Urs Hölzle promotes it#footnote[#link("https://opennetworking.org/wp-content/uploads/2013/02/cs-googlesdn.pdf")[Inter-Datacenter WAN with centralized TE using SDN and OpenFlow.]]) #v(1em)
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
      "OF 1.0", "Dec 2009", "12 fields (Ethernet, TCP/IPv4)",
      "OF 1.1", "Feb 2011", "15 fields (MPLS, inter-table metadata)",
      "OF 1.2", "Dec 2011", "36 fields (APR, ICMP, IPv6, etc.)",
      "OF 1.3", "Jun 2012", "40 fields",
      "OF 1.4", "Oct 2013", "41 fields",
  )

  More Details on the OpenFlow v1.0.0 Switch Specification #footnote[
      https://opennetworking.org/wp-content/uploads/2013/04/openflow-spec-v1.0.0.pdf
  ]
]

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

  #v(-1em)

  #one-by-one(start: 1, mode: "transparent")[
      *New Control Plane Specification*: P4Runtime for controlling the data plane elements of a device defined by a P4 program

  ][
      *Reconfigurability*: the controller should be able to redefine the packet parsing and processing in the field

    ][
        *Protocol Independence*: the switch should process _headers_ using parsing and processing using _match+action_ tables

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
    == Real Case Scenario
    #v(-1em)

    #align(left)[
        #text(small-size)[Setup: *L2 Network Architecture*]
        #text(tiny-size)[
            - _Edge (top-of-rack switches)_: connect end-hosts to the network
            - _Core_: central layer that connects the edge devices
        ]

        #text(small-size)[Problem: *Growing End-Hosts and Overflowing Tables*]
            #text(tiny-size)[
                - The L2 forwarding tables in the _core_ are becoming too large $arrow$ *overflow*
                - It can cause _packet loss_ and _network congestion_
        ]

        #text(small-size)[Solutions: *Muti-protocol Label Switching and PortLand*]
        #text(tiny-size)[
            - _MPLS_: a technique that uses labels to make data forwarding decisions $arrow$ *with multiple tags is daunting*
            - _PortLand_: a scalable L2 network architecture $arrow$ *rewrite MAC addresses*
        ]
    ]
]

#slide[
    = P4: Language Design

    #v(2em)

    *Header*: #text(0.9em)[describes the structure of a series of fields and constraints on values]

    *Parser*: #text(0.9em)[specifies how to identify headers and valid header sequences]

    *Table*: #text(0.9em)[defines the fields to match on and the actions to take]

    *Action*: #text(0.9em)[construction of actions from simpler protocol-independent primitives]

    *Control Programs*: #text(0.9em)[determines the order of match+action tables that are applied to a packet]
]


#slide[
    == Header
    #v(-2em)
    _Describes the structure of a series of fields and constraints on values_

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
    == Header (Cont.)
    #side-by-side(columns: (auto, auto))[
    #raw(
"header mTag {
  fields {
    up1: 8;
    up2: 8;
    down1: 8;
    down2: 8;
    ethertype: 16;
  }
}", lang: "c++")][
    - _mTag_ can be added without altering the existing headers
    - The core has two layers of aggregation
    - Each core switch examines on of these bytes detemined by its *location* and the *direction* of the packet
    ]
]

#slide[
    == Parser
    #v(-2em)
    _Specifies how to identify headers and valid header sequences_
    #align(center)[#raw("parser start { ethernet; }", lang: "c++")]
    #side-by-side[
        #raw(
"parser ethernet {
  switch(ethertype) {
    case 0x8100: vlan;
    case 0x9100: vlan;
    case 0x800: ipv4;
    // Other cases
  }
}", lang: "c++")
    ][
        #raw(
"parser vlan {
  switch(ethertype) {
    case 0xaaaa: mTag;
    case 0x800: ipv4;
    // Other cases
  }
}
", lang: "c++")
    ]

]

#slide[
    == Parser (Cont.)
    #v(1em)
    #side-by-side(columns: (auto, auto))[
        #raw(
"parser mTag {
  switch(ethertype) {
    case 0x800: ipv4;
    // Other cases
  }
}", lang: "c++")
    ][
        - Reached a state for a new header, the State Machine extracts the header and sends it to the match+action pipeline
        - The parser for _mTag_ is simple, it has only four states
    ]

]
#slide[
    == Table
    #v(-2em)
    _Defines the fields to match on and the actions to take_
    #side-by-side(columns: (auto, auto))[
    #text(small-size)[
      #raw(
"table mTag_table {
  reads {
    ethernet.dst_addr: exact;
    vlan.vid: exact;
  }
  actions {
    // At runtime, entries are
    // programmed with params
    // for the mTag action.
    add_mTag;
  }
  max_size: 20000;
}", lang: "c++")
    ]][
        The compiler knows what memory type use (e.g., TCAM, SRAM) and the amount of memory to allocate

        - `reads`: the edge switch matches on the L2 destination address and the VLAN ID
        - `actions`: selects an _mTag_ to add to the header
        - `max_size`: the maximum number of entries
    ]
]

#slide[
    == Action
    #v(-2em)
    _Construction of actions from simpler protocol-independent primitives_
    #side-by-side(columns: (60%, 40%))[
    #text(small-size)[
        #raw(
"action add_mTag(up1, up2, down1, down2, egr_spec) {
  add_header(mTag);
  // Copy VLAN ethertype to mTag
  copy_field(mTag.ethertype, vlan.ethertype);
  // Set VLAN’s ethertype to signal mTag
  set_field(vlan.ethertype, 0xaaaa);
  set_field(mTag.up1, up1);
  set_field(mTag.up2, up2);
  set_field(mTag.down1, down1);
  set_field(mTag.down2, down2);
  // Set the destination egress port as well
  set_field(metadata.egress_spec, egr_spec);
}
    ", lang: "c++")
]
    ][
      - P4 assumes parallel execution
      - Parameters are passed from the match table at runtime
      - The switch inserts the _mTag_ afer the VLAN header
    ]
]

#slide[
    == Control Programs
    #v(-2em)
    _Determines the order of match+action tables that are applied to a packet_
    #side-by-side(columns: (auto, auto))[
        #text(0.6em)[
            #raw(
"control main() {
  // Verify mTag state and port are consistent
  table(source_check);
  // If no error from source_check, continue
  if (!defined(metadata.ingress_error)) {
    // Attempt to switch to end hosts
    table(local_switching);
    if (!defined(metadata.egress_spec)) {
      // Not a known local host; try mtagging
      table(mTag_table);
    }
    // Check for unknown egress state or
    // bad retagging with mTag.
    table(egress_check);
  }
}", lang: "c++")
        ]][
            #text(small-size)[
                - _mTag_ should only be seen on ports to the core

                - `source_check` strips the _mTag_ and records it in the metadata to avoid retagging

                - If the `local_switching` table misses, the packet is not destined for a local host

                - Both _local_ and _core_ forwarding control is handled by the `egress_check` table

                - If unknown destination, the SDN controller is notified during `egress_check`
            ]
        ]
]

#slide[
    = P4: Compilation Process

    #v(2em)

    - The P4 compiler translates the P4 program into a _target-independent_ representation #text(tiny-size)[(TDGs)]

    - The TDGs are compiled into _target-dependent_ code

    - The compiler can optimize the table layout to minimize the number of tables and the number of lookups

    - The compiler can detect data dependencies and arrange tables in parallel or in series
]

#slide[
    == Compiling Packet Parsers

    #v(2em)

    - For devices with _programmable_ parsers, the compiler generates the parser state machine #text(tiny-size)[(see PISA architecture)]

    #v(1em)

    - For devices with _fixed_ parsers, the compiler verifies that the parser description is _consistent_ with the device's fixed parser #text(tiny-size)[(e.g., ASICs)]
]

#slide[
    == Compiling Packet Parsers (Cont.)

    _Parser state table entries for the `vlan` and `mTag` sections of the parser_

    #align(center)[
    #table(
        columns: (auto, auto, auto),
        align: center,
         table.header(
             "Current Version",
             "Lookup Value",
             "Next State"
         ),
        `vlan`, "0xaaaa", `mTag`,
        `vlan`, "0x800",  `ipv4`,
        `vlan`, "*",      "stop",
        `mTag`, "0x800",  `ipv4`,
        `mTag`, "*",      "stop",
    )]

    #text(small-size)[The \* is a wildcard that matches any value]

    #text(small-size)[The stop state indicates that the parser has finished processing the packet]
]

#slide[
    == Compiling Control Programs

    #one-by-one(start: 1, mode: "transparent")[
        #align(center)[_The imperative control-flow representation does not call out dependencies between tables or opportunities for concurrency_]
        #v(1em)
    ][
        1. The compiler analyzes the `control` program to determine dependencies between tables and opportunities for concurrency

    ][
        2. The compiler generates the target configuration for the switch

    ][
        #align(center)[
            *Is this not familiar?*
            #v(-1em)
            #text(tiny-size)[Two-stage compilation]
        ]
    ]
]

#slide[
    == 1. Software Switches

    #side-by-side[
        - *Software Switches* provide complete flexibility:

          1. Table Count #v(1em)

          2. Table Configuration #v(1em)

          3. Parsing under SW control
    ][
        - The compiler:

            1. Maps the `mTag` table graph to switch tables
            2. Uses table type to constrain width, height, and matching criterion
            3. Can optimize ternary matches with SW data structures
    ]
]

#slide[
    == 2. Hardware Switches with RAM and TCAM

    #align(center)[
        #v(1em)

        In *edge* switches, the compiler configure hashing to perform efficient exact-matching using RAM

        #v(2em)

        In *core* switches, which match on a subset of fields, the compiler maps the table to TCAM
    ]
]

#slide[
    == 3. Switches supporting parallel tables

    #align(center)[
        #v(1em)

        The compiler can *detect* data dependencies and arrange tables in parallel or in series

        #v(2em)

        In the `mTag` example, the `mTag_table` and `local_switching` tables can be executed in parallel up to the `add_mTag` action
    ]
]

#slide[
    == 4. Switches that apply actions at the end of the pipeline

    #align(center)[
        #v(1em)
        The compiler can *tell* to the intermediate stages to generate metadata for the final action

        #v(2em)

        In the `mTag` example, whether the `mTag` is added or not could be represented in metadata
    ]
]


#slide[
    == 5. Switches with a few tables

    #align(center)[
        The compiler can *optimize* the table layout to minimize the number of tables and the number of lookups

        When a controller installs a rule (at runtime), the compiler can generate P4 tables to generate the rules for the single physical table

        #v(2em)

        In the `mTag` example, the `local_switching` table could be merged with the `mTag_table`
    ]
]

#polylux-slide[
    #align(center)[
        = Thanks for your attention!

        Slides available at
        #v(-1em)
        #text(0.9em)[
            #link("https://federicobruzzone.github.io/activities/presentations/P4-compiler-in-SDN.pdf")[federicobruzzone.github.io/activities/presentations/P4-compiler-in-SDN.pdf]
        ]
    ]

    #v(1em)

    #table(
        columns: (1fr, 3fr),
        align: (right, left),
        "Website",  link("https://federicobruzzone.github.io/")[federicobruzzone.github.io],
        "Github",   link("https://github.com/FedericoBruzzone")[github.com/FedericoBruzzone],
        "𝕏",        link("https://x.com/fedebruzzone7")[\@fedebruzzone7],
        "LinkedIn", link("https://www.linkedin.com/in/federico-bruzzone/")[in/federico-bruzzone],
        "Telegram", link("https://t.me/federicobruzzone")[\@federicobruzzone],
        "Email 1",  link("mailto:federico.bruzzone@unimi.it")[federico.bruzzone\@unimi.it],
        "Email 2",  link("mailto:federico.bruzzone.i@gmail.com")[federico.bruzzone.i\@gmail.com],
    )
]

// #hidden-bibliography(
#bibliography("local.bib")
// )

#slide[
  == Table (Addition)
  #v(-1em)
  #text(small-size)[
        #raw(
"table source_check {
  // Verify mtag only on ports to the core
  reads {
    mtag : valid; // Was mtag parsed?
    metadata.ingress_port : exact;
  }
  actions { // Each table entry specifies *one* action
    // If inappropriate mTag, send to CPU
    fault_to_cpu;
    // If mtag found, strip and record in metadata
    strip_mtag;
    // Otherwise, allow the packet to continue
    pass;
  }
  max_size: 64; // One rule per port
}", lang: "c++")
  ]
]

#slide[
  == Table (Addition)
  #v(-1em)
  #text(small-size)[
        #raw(
"table local_switching {
  // Reads destination and checks if local
  // If miss occurs, goto mtag table.
}
table egress_check {
  // Verify egress is resolved
  // Do not retag packets received with tag
  // Reads egress and whether packet was mTagged
}", lang: "c++")
  ]
]

// Old setup

// #import "@preview/polylux:0.3.1": *
// #import "@preview/hidden-bib:0.1.0": hidden-bibliography
// #import themes.simple: *
// #show: simple-theme.with( aspect-ratio: "16-9", footer: [Federico Bruzzone -- Adapt Lab -- Università degli Studi di Milano], background: background, foreground: foreground,)
