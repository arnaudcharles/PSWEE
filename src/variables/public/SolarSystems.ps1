$script:SolarSystems = @(
    @{
        Name    = 'Solar System'
        Planets = $script:Planets
        Moons   = $script:Moons
    },
    @{
        Name    = 'Alpha Centauri'
        Planets = @()
        Moons   = @()
    },
    @{
        Name    = 'Sirius'
        Planets = @()
        Moons   = @()
    }
)
