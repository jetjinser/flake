{ lib
, ...
}:

let
  fs = lib.fileset;
  excludeSelfFilter = self:
    let
      ft = builtins.readFileType self;
      self' = if ft == "directory" then self + /default.nix else self;
    in
    fs.difference self self';
  isNixFilter = path: fs.fileFilter (file: file.hasExt "nix") path;
  idFilter = fs.fileFilter (_: true);
in
{
  importx =
    path:
    { filter ? idFilter
    }:
    let
      fileSet = fs.intersection
        (filter path)
        (fs.intersection
          (excludeSelfFilter path)
          (isNixFilter path));
    in
    fs.toList fileSet;
}
