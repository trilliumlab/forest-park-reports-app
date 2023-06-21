import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'panel_position_provider.g.dart';

enum PanelPositionState {
  open,
  closed,
  snapped
}

class PanelPositionUpdate {
  final PanelPositionState position;
  final bool move;
  PanelPositionUpdate(this.position, this.move);
}

@riverpod
class PanelPosition extends _$PanelPosition {
  @override
  PanelPositionUpdate build() => PanelPositionUpdate(PanelPositionState.closed, false);

  void move(PanelPositionState position) {
    state = PanelPositionUpdate(position, true);
  }
  void update(PanelPositionState position) {
    state = PanelPositionUpdate(position, false);
  }
}
