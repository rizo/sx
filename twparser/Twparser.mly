
class_names:
  | utility EOF {  $1 }


utility:
  | margin
  | padding
