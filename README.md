```md
# WARNING

Nothing in here should be used yet. You have been warned.
```

# anna keyboard family

| name    | switch footprint | spacing | use     | controller          | keys   | features                   | rev | phase      |
|:--------|:-----------------|:--------|:--------|:--------------------|:-------|:---------------------------|-----|------------|
| Lasagna | MX Kailh Hotswap | MX      | Typing  | bluetooth pro micro | 16     | trackball, rotary encoder  | 0.1 | unfinished |
| EDC     | MX Kailh Hotswap | MX      | Typing  | bluetooth pro micro | 36     | nothing special            | 0.1 | unfinished |
| Squared | Kailh Choc V2    | MX      | Typing  | bluetooth pro micro | 36     | low profile                | xxx | idea       |
| Daemon  | MX Kailh Hotswap | MX      | Macro   | bluetooth pro micro | ???    | trackball                  | xxx | idea       |
| Mouse   | Kailh Choc V1    | Choc    | Typing  | bluetooth pro micro | 36     | very low profile           | xxx | idea       |
| Bread   | MX Kailh Hotswap | MX      | Testing | bluetooth pro micro | 26     | first prototype, trackball | --- | cancelled  |


## How to build

Either use the github action and its artifacts **or** install [act](https://github.com/nektos/act) and run `act -b` in the repository root.

The makefile contains targets for a light build (only ergogen) and a full build (as in the cloud).

## Previews

### Lasagna
![](./previews/lasagna_board.png)