import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PanelPosition {
  open,
  closed,
  snapped
}
class PanelPositionUpdate {
  final PanelPosition position;
  final bool move;
  PanelPositionUpdate(this.position, this.move);
}
class PanelPositionNotifier extends StateNotifier<PanelPositionUpdate> {
  PanelPositionNotifier() : super(PanelPositionUpdate(PanelPosition.closed, false));

  void move(PanelPosition position) {
    state = PanelPositionUpdate(position, true);
  }
  void update(PanelPosition position) {
    state = PanelPositionUpdate(position, false);
  }
}
final panelPositionProvider = StateNotifierProvider<PanelPositionNotifier, PanelPositionUpdate>
  ((ref) => PanelPositionNotifier());
