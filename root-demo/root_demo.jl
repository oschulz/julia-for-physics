using ROOT

# Create a ROOT histogram, fill it with random events, and fit it.
h = ROOT.TH1D("h", "Normal distribution", 100, -5., 5.)
FillRandom(h, "gaus")

#Draw the histogram on screen
c = ROOT.TCanvas()
Draw(h)

#Fit the histogram wih a normal distribution
Fit(h, "gaus")

SaveAs(c, "demo_ROOT.png")
