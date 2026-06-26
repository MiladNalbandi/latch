/* Latch icon set — Lucide-style line icons (24×24, 2px stroke, round caps/joins).
   Latch uses the Lucide icon system; these are inline renders so kits work offline.
   Each is a small React component taking {size, ...rest}. Exported to window. */
(function () {
  const S = (paths, vb) => ({ size = 18, strokeWidth = 2, ...rest }) =>
    React.createElement("svg", {
      width: size, height: size, viewBox: vb || "0 0 24 24", fill: "none",
      stroke: "currentColor", strokeWidth, strokeLinecap: "round", strokeLinejoin: "round", ...rest,
    }, paths.map((d, i) => React.createElement("path", { key: i, d })));

  const Circle = (cx, cy, r) => React.createElement("circle", { cx, cy, r, key: "c" + cx });

  const Icons = {
    Search: ({ size = 18, strokeWidth = 2, ...r }) => React.createElement("svg",
      { width: size, height: size, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", strokeWidth, strokeLinecap: "round", strokeLinejoin: "round", ...r },
      Circle(11, 11, 7), React.createElement("path", { d: "m21 21-4.3-4.3", key: "p" })),
    Clipboard: S(["M9 3h6a1 1 0 0 1 1 1v1a1 1 0 0 1-1 1H9a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1z", "M8 5H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2"]),
    Pin: S(["M9.5 3h5l-.8 5 3.3 3.2V14h-5.5v6l-1 1.5-1-1.5v-6H4v-2.8L7.3 8 6.5 3z"]),
    Star: S(["m12 3 2.6 5.3 5.9.9-4.2 4.1 1 5.8L12 16.9 6.7 19.6l1-5.8-4.2-4.1 5.9-.9L12 3z"]),
    Lock: ({ size = 18, strokeWidth = 2, ...r }) => React.createElement("svg",
      { width: size, height: size, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", strokeWidth, strokeLinecap: "round", strokeLinejoin: "round", ...r },
      React.createElement("rect", { x: 4.5, y: 10.5, width: 15, height: 10, rx: 2, key: "r" }),
      React.createElement("path", { d: "M8 10.5V7a4 4 0 0 1 8 0v3.5", key: "p" })),
    Settings: ({ size = 18, strokeWidth = 2, ...r }) => React.createElement("svg",
      { width: size, height: size, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", strokeWidth, strokeLinecap: "round", strokeLinejoin: "round", ...r },
      Circle(12, 12, 3),
      React.createElement("path", { d: "M19.4 15a1.6 1.6 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.6 1.6 0 0 0-1.8-.3 1.6 1.6 0 0 0-1 1.5V21a2 2 0 0 1-4 0v-.1a1.6 1.6 0 0 0-1-1.5 1.6 1.6 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.6 1.6 0 0 0 .3-1.8 1.6 1.6 0 0 0-1.5-1H3a2 2 0 0 1 0-4h.1a1.6 1.6 0 0 0 1.5-1 1.6 1.6 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.6 1.6 0 0 0 1.8.3H9a1.6 1.6 0 0 0 1-1.5V3a2 2 0 0 1 4 0v.1a1.6 1.6 0 0 0 1 1.5 1.6 1.6 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.6 1.6 0 0 0-.3 1.8V9a1.6 1.6 0 0 0 1.5 1H21a2 2 0 0 1 0 4h-.1a1.6 1.6 0 0 0-1.5 1z", key: "p" })),
    Link: S(["M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1.5 1.5", "M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1.5-1.5"]),
    Image: ({ size = 18, strokeWidth = 2, ...r }) => React.createElement("svg",
      { width: size, height: size, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", strokeWidth, strokeLinecap: "round", strokeLinejoin: "round", ...r },
      React.createElement("rect", { x: 3, y: 4, width: 18, height: 16, rx: 2, key: "r" }),
      Circle(8.5, 9.5, 1.5),
      React.createElement("path", { d: "m5 18 5-5 3 3 2-2 4 4", key: "p" })),
    Code: S(["m9 8-4 4 4 4", "m15 8 4 4-4 4"]),
    File: S(["M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z", "M14 3v5h5"]),
    Plus: S(["M12 5v14M5 12h14"]),
    X: S(["M18 6 6 18M6 6l12 12"]),
    Trash: S(["M4 7h16", "M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2", "M6 7l1 13a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1l1-13"]),
    Check: S(["M5 12.5 10 17 19 7"]),
    ChevronRight: S(["m9 6 6 6-6 6"]),
    Command: S(["M9 9V6a3 3 0 1 0-3 3h12a3 3 0 1 0-3-3v3m0 6v3a3 3 0 1 0 3-3H6a3 3 0 1 0 3 3v-3m0-6h6v6H9z"]),
    Sparkles: S(["M12 4l1.6 4.4L18 10l-4.4 1.6L12 16l-1.6-4.4L6 10l4.4-1.6L12 4z", "M19 15l.7 2 2 .7-2 .7-.7 2-.7-2-2-.7 2-.7.7-2z"]),
    Shield: S(["M12 3l7 3v5c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6l7-3z"]),
    Clock: ({ size = 18, strokeWidth = 2, ...r }) => React.createElement("svg",
      { width: size, height: size, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", strokeWidth, strokeLinecap: "round", strokeLinejoin: "round", ...r },
      Circle(12, 12, 9), React.createElement("path", { d: "M12 7v5l3 2", key: "p" })),
    Type: S(["M5 6h14", "M12 6v13", "M9 19h6"]),
    Apple: S(["M16 12c0-2 1.5-3 1.5-3-1-1.5-2.5-1.6-3-1.6-1.3-.1-2.5.8-3.1.8-.6 0-1.6-.8-2.7-.8C6.4 7.5 5 9 5 11.7c0 2.8 2 6.3 3.6 6.3.8 0 1.3-.6 2.4-.6s1.4.6 2.4.6c1.6 0 3.1-2.8 3.1-3.5 0 0-1.9-.8-1.9-2.5z", "M13 5.5c.6-.8.6-1.8.5-2.5-.9.1-1.7.6-2.2 1.2-.5.6-.7 1.5-.6 2.3.9 0 1.7-.4 2.3-1z"]),
  };

  window.LatchIcons = Icons;
})();
