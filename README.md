# flutter_location_picker

A new Flutter project.

## Usage


```dart

LocationPicker.showPicker(
  context,
  showTitleActions: true,
  initialProvince: '上海',
  initialCity: '上海',
  initialTown: null,
  onChanged: (p, c, t) {
    print('$p $c $t');
  },
  onConfirm: (p, c, t) {
    print('$p $c $t');
  },
);


```