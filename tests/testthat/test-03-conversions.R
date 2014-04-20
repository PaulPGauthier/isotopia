context("Data Conversion")

test_that("Testing that isotope data type conversations behave correctly", {
    expect_error(abundance(ratio(.1)), "Cannot initialize an isotope value with another isotope value")
    
    #  initialization tests and keeping attributes
    expect_error(as.ratio("test"), "Don't know how to convert object of class .* to isotope ratio")
    expect_identical(as.ratio(ratio(.1)), ratio(.1))
    expect_identical(as.ratio(ratio(.1, .2)), ratio(.1, .2))
    expect_error(as.abundance("test"), "Don't know how to convert object of class .* to isotope abundance")
    expect_identical(as.abundance(abundance(.1)), abundance(.1))
    expect_identical(as.abundance(abundance(.1, .2)), abundance(.1, .2))
    expect_is(r <- as.ratio(a <- abundance(`13C` = .1, major = "12C", compound = "CO2")), "Ratio")
    expect_equal(r@isoname, a@isoname)
    expect_equal(r@major, a@major)
    expect_equal(r@compound, a@compound)
    expect_error(as.delta("test"), "Don't know how to convert object of class .* to delta value")
    
    # conversions to primtivie
    expect_identical(as.value(ratio(0.1*(1:5))), 0.1*(1:5))
    expect_equal(as.value(ratio(a = 1:5, b = 6:10)), data.frame(a = 1:5, b = 6:10))
    
    # conversation from abundance to ratio
    expect_equal(as.ratio(abundance(.4)), ratio(.4/.6)) # convertion of single abundance to ratio
    x <- c(0.0001, 0.001, 0.01, 0.1, 0.5) 
    expect_equal(as.ratio(abundance(x)), ratio(x / (1 - x))) # converting multiple values with the formula
    expect_equal(as.ratio(abundance(.1, .3)), ratio(.1/.6, .3/.6)) # convertion of abundance system to ratio system
    y <- sample(x)/5 
    expect_equal(as.ratio(abundance(x, y)), ratio(x / (1 - x - y), y / (1 - x - y))) # converting multiple values in a system
    
    # conversation from ratio to abundance
    expect_equal(as.abundance(ratio(.2)), abundance(.2/1.2)) # convertion of single ratio to abundance
    expect_equal(as.abundance(ratio(x)), abundance(x / (1 + x))) # converting multiple values with the formula
    expect_equal(as.abundance(ratio(.2, .3)), abundance(.2/1.5, .3/1.5)) # convertion of ratio system to abundance system
    expect_equal(as.abundance(ratio(x, y)), abundance(x / (1 + x + y), y / (1 + x + y))) # converting multiple values in a system
    
    # back and forth conversions
    ab <- abundance(x, y)
    expect_equal(as.abundance(as.ratio(ab)), ab)
    expect_true(all(abs(as.value(as.abundance(as.ratio(ab))) - as.value(ab)) < 10^(-15))) # test that machine error from back and forth conversion is smaller than 10^-15
    
    # conversion from intensity to ratio and abundace
    expect_error(as.ratio(intensity(100)), "Don't know how to convert object of class Intensity to isotope ratio")
    expect_error(as.ratio(intensity(100, 1000)), "none of the isotopes .* could be identified as the major ion")
    expect_error(intensity(intensity(`13C` = 100, major = "13C"), intensity(`12C` = 1000, major = "12C")), "major ion of all isotope value object in an isotope system must be the same")
    expect_is({ # single ratio conversion
        is <- intensity(`12C` = 1000, `13C` = 100, major = "12C", unit = "#", compound = "CO2")
        rs <- as.ratio(is)
    }, "Ratios")
    expect_equal(names(rs)[1], "13C")
    expect_equal(rs$`13C`@major, "12C")
    expect_equal(rs$`13C`@compound, "CO2")
    expect_equal(rs$`13C`, ratio(`13C` = 100/1000, major = "12C", compound = "CO2"))
    expect_is({ # multiple ratio conversions
        is <- intensity(`32S` = 9502, `33S` = 75, `34S` = 421, `36S` = 2, major = "32S", unit = "#")
        rs <- as.ratio(is)
    }, "Ratios")
    expect_equal(rs, ratio(`33S` = 75/9502, `34S` = 421/9502, `36S` = 2/9502, major = "32S")) # value check 
    expect_equal(as.ratio(intensity(x = x, y = y, major = "x")), ratio(y = y/x, major = "x", single_as_df = T)) # formula check
    expect_is(ab <- as.abundance(is), "Abundances")
    expect_equal(ab, abundance(`33S` = 0.0075, `34S` = 0.0421, `36S` = 0.0002, major = "32S")) # value check
    expect_equal(as.abundance(intensity(x = x, y = y, major = "x")), abundance(y = y/(y + x), major = "x", single_as_df = T)) # formula check

    # ratios to alpha
    expect_equal(as.alpha(ratio(0.1), ratio(0.2)), alpha(0.5)) # more test details in the arithmetic tests
     
    # alpha to epsilon
    expect_true(use_permil()) # check the default is set to use permil
    expect_equal(ex <- as.epsilon(alpha(0.99)), epsilon(-10, permil = T))
    expect_equal(e <- as.epsilon(alpha(0.99), permil = F), epsilon(-0.01, permil = F))
    expect_is(es <- as.epsilon(alpha(a = 0.99, b = 1.02)), "Epsilons")
    expect_equal(es$a, epsilon(a = -10))
    expect_equal(es$b, epsilon(b = +20))
    
    # epsilon/delta to alpha
    expect_equal(as.alpha(epsilon(10)), alpha(1.01))
    expect_equal(as.alpha(epsilon(-0.02, permil = F)), alpha(0.98))
    expect_equal(as.alpha(delta(-0.02, permil = F)), alpha(0.98))
    
    # epsilons/deltas to fractionation factor (alpha) and to epsilons
    expect_equal(as.alpha(delta(200), delta(-200)), alpha(1.2 / 0.8))
    expect_equal(as.epsilon(as.alpha(delta(200), delta(-200)), permil = F), epsilon(1.2 / 0.8 - 1, permil = F))
                 
    # epsilon conversions (permil testing)
    expect_true(use_permil()) # check the default is set to use permil
    expect_is(ex <- as.epsilon(epsilon(0.02, permil = F)), "Epsilon")
    expect_equal(ex@permil, TRUE)
    expect_equal(as.value(ex), 20)
    expect_equal(label(ex), "ε [‰]")
    expect_is(e <- as.epsilon(epsilon(20), permil = F), "Epsilon")
    expect_equal(e@permil, FALSE)
    expect_equal(as.value(e), 0.02)
    expect_equal(label(e), "ε")
    expect_is(ex <- as.epsilon(epsilon(a = 0.02, b = 0.01, permil = F)), "Epsilons") # test isotope system
    expect_equal(as.value(ex$a), 20)
    expect_equal(as.value(ex$b), 10)
    expect_equal(as.value((e <- as.epsilon(ex, permil = F))$a), 0.02)
    expect_equal(as.value(e$b), 0.01)
    
    # delta conversions (permil conversion)
    expect_true(use_permil()) # check the default is set to use permil
    expect_is(dx <- as.delta(delta(0.02, permil = F)), "Delta")
    expect_equal(dx@permil, TRUE)
    expect_equal(as.value(dx), 20)
    expect_equal(label(dx), "δ [‰]")
    expect_is(d <- as.delta(delta(20), permil = F), "Delta")
    expect_equal(d@permil, FALSE)
    expect_equal(as.value(d), 0.02)
    expect_equal(label(d), "δ")
    expect_is(dx <- as.delta(delta(a = 0.02, b = 0.01, permil = F)), "Deltas") # test isotope system
    expect_equal(as.value(dx$a), 20)
    expect_equal(as.value(dx$b), 10)
    expect_equal(as.value((d <- as.delta(dx, permil = F))$a), 0.02)
    expect_equal(as.value(d$b), 0.01)
    
    # epsilon to delta
    expect_false(use_permil(FALSE)) # mixing it up a bit
    expect_is(dx <- as.delta(epsilon(0.02), permil = T), "Delta")
    expect_true(dx@permil)
    expect_equal(as.value(dx), 20)
    expect_true(use_permil(TRUE)) # return it back to normal
    
    # with ratio specified
    expect_error(as.delta(epsilon(20), ref_ratio = c(0.1, 0.2)), "reference ratio .* must be exactly one numeric value")
    expect_error(as.delta(epsilon(`13C` = 20), ref_ratio = ratio(`12C` = 0.1)), "reference ratio .* cannot be for a different isotope")
    expect_error(as.delta(epsilon(20, major = "14N"), ref_ratio = ratio(0.1, major = "12C")), "reference ratio .* cannot have a different major isotope")
    expect_error(as.delta(delta(20, ref = "SMOW"), ref_ratio = ratio(0.1, compound = "air")), "reference ratio .* cannot be a different compound than already specifie")
    expect_error(as.delta(delta(20, ref_ratio = 0.1), ref_ratio = 0.2), "reference ratio .* cannot be different than previous specification")
    expect_is(d <- as.delta(delta(20), ref_ratio = ratio(0.1, compound = "SMOW"), permil = F), "Delta")
    expect_equal(as.value(d), 0.02)
    expect_equal(d@compound2, "SMOW")
    expect_equal(d@ref_ratio, 0.1)
    
    # alpha to delta
    expect_equal(as.delta(alpha(0.99)), delta(-10))
    expect_equal(as.delta(alpha(0.99), permil = F), delta(-0.01, permil = F))
    expect_equal(as.delta(alpha(0.99), ref_ratio = 0.1), delta(-10, ref_ratio = 0.1))
    expect_equal(as.delta(alpha(0.99), ref_ratio = ratio(0.1, compound = "air")), delta(-10, ref_ratio = 0.1, ref = "air"))
    
    # ratio to delta
    expect_error(as.delta(ratio(c(0.18, 0.16)), ratio(c(0.2, 0.3))), "reference ratio for a delta value object must be exactly one numeric value")
    expect_equal(as.delta(ratio(0.18), ratio(0.2)), delta(-100, ref_ratio = 0.2))
    x <- runif(20, min = 0.1, max = 0.2) # random ratios
    expect_equal(as.delta(ratio(x), 0.2), delta((x/0.2 - 1) * 1000, ref_ratio = 0.2))
    expect_equal(as.delta(ratio(0.18), 0.2, permil = F), delta(-0.1, ref_ratio = 0.2, permil = F))
    expect_error(as.delta(ratio(`13C` = 0.18), ratio(`18O` = 0.2)), "cannot generate a fractionaton factor from two ratio objects that don't have matching attributes")
    expect_error(as.delta(ratio(0.18, major = "12C"), ratio(0.2, major = "13C")), "annot generate a fractionaton factor from two ratio objects that don't have matching attributes")
    expect_equal(label(d <- as.delta(ratio(`13C` = 0.18, major = "12C", compound = "CO2"), 
                                     ratio(`13C`= 0.2, major = "12C", compound = "SMOW"))), "CO2 δ13C [‰] vs. SMOW")
    expect_equal(d@major, "12C")
    
    # systems
    expect_error(as.delta(ratio(0.1, 0.2), ratio(0.1, 0.2)), "the proper way .* not implemented yet")
    
    # abundance to delta
    expect_error(as.delta(abundance(0.2)), "not currently implemented")  # work here
    
    # delta back to ratio
    expect_error(as.ratio(delta(20)), "cannot convert from a ratio to a delta value without the reference ratio set")
    expect_equal(as.ratio(delta(-100, ref_ratio = 0.2)), ratio(0.18))
    x <- runif(20, min = -100, max = 100) # random delta values
    expect_equal(as.ratio(delta(x, ref_ratio = 0.2)), ratio((x/1000 + 1) * 0.2)) # test equation
    expect_equal(as.ratio(delta(`13C` = -100, major = "12C", compound = "CO2", ref_ratio = 0.2)), 
                 ratio(`13C` = 0.18, major = "12C", compound = "CO2")) # test parameters
    expect_message(as.ratio(delta(`2H` = -100, major = "1H", ref = "VSMOW")), "Successfully found a matching standard")
    
})
 

test_that("Testing that additional data in Isosys data frames doesn't get lost during conversions", {
    expect_is({
        is <- intensity(`32S` = 9502, `33S` = 75, `34S` = 421, `36S` = 2, major = "32S", unit = "#")
        is$extra <- 'test'
        is <- is[c(1,2,5,4,3)]
        rs <- as.ratio(is)
    }, "Ratios")
    expect_equal(names(rs), c("33S", "extra", "36S", "34S"))
    expect_equal(rs$extra, "test")
    expect_is({
        rs$time <- 0.234
        ab <- as.abundance(rs)
    }, "Abundances")
    expect_equal(ab$extra, "test")
    expect_equal(rs$time, 0.234)
})