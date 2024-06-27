using UnROOT, TypedTables

f = UnROOT.samplefile("km3net_offline.root")

t = LazyTree(f, "E", ["Evt/trks/trks.id", r"Evt/trks/trks.pos.[xyz]"])

names(t)

t.Evt_trks_trks_pos_y

t[1]
