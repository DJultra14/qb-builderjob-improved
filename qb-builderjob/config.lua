Config = Config or {}

Config.Pay = 500

Config.CurrentProject = 0
Config.Projects = {
    [1] = {
        IsActive = false,
        ProjectLocations = {
            ["main"] = {
                label = "Loc 1",
                coords = {x = -921.5, y = 378.31, z = 79.5, h = 92.5, r = 1.0},
            },
            ["tasks"] = {
                [1] = {
                    coords = {x = -924.28, y = 396.87, z = 79.09, h = 11.5, r = 1.0},
                    type = "hammer",
                    completed = false,
                    label = "Hammer",
                    IsBusy = false,
                },
                [2] = {
                    coords = {x = -937.67, y = 381.6, z = 77.07, h = 128.86, r = 1.0},
                    type = "mix",
                    completed = false,
                    label = "Mix",
                    IsBusy = false,
                },
                [3] = {
                    coords = {x = -937.33, y = 385.65, z = 77.62, h = 349.5, r = 1.0},
                    type = "look",
                    completed = false,
                    label = "Inspect",
                    IsBusy = false,
                },
                [4] = {
                    coords = {x = -939.93, y = 390.53, z = 77.73, h = 26.3, r = 1.0},
                    type = "janitor",
                    completed = false,
                    label = "Sweep",
                    IsBusy = false,
                },
                [5] = {
                    coords = {x = -962.34, y = 387.54, z = 72.94, h = 31.29, r = 1.0},
                    type = "drill",
                    completed = false,
                    label = "Drill",
                    IsBusy = false,
                },
                [6] = {
                    coords = {x = -932.54, y = 393.47, z = 79.15, h = 25.68, r = 1.0},
                    type = "weld",
                    completed = false,
                    label = "Weld",
                    IsBusy = false,
                },
            }
        }
    },
}