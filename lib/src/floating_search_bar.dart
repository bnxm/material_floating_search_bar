import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart'
    hide ImplicitlyAnimatedWidget, ImplicitlyAnimatedWidgetState;
import 'package:flutter/services.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'floating_search_bar_actions.dart';
import 'floating_search_bar_dismissable.dart';
import 'floating_search_bar_transition.dart';
import 'search_bar_style.dart';
import 'text_controller.dart';
import 'util/util.dart';
import 'widgets/widgets.dart';

part 'floating_search_app_bar.dart';

// ignore_for_file: public_member_api_docs

typedef FloatingSearchBarBuilder = Widget Function(
    BuildContext context, Animation<double> transition);

/// An expandable material floating search bar with customizable
/// transitions similar to the ones used extensively
/// by Google in their apps.
class FloatingSearchBar extends ImplicitlyAnimatedWidget {
  /// The widget displayed below the `FloatingSearchBar`.
  ///
  /// This is useful, if the `FloatingSearchBar` should react
  /// to scroll events (i.e. hide from view when a [Scrollable]
  /// is being scrolled down and show it again when scrolled up).
  final Widget body;
  // * --- Style properties --- *

  /// The color used for elements such as the progress
  /// indicator.
  ///
  /// Defaults to the themes accent color if not specified.
  final Color accentColor;

  /// The color of the card.
  ///
  /// If not specified, defaults to `theme.cardColor`.
  final Color backgroundColor;

  /// The color of the shadow drawn when `elevation > 0`.
  ///
  /// If not specified, defaults to `Colors.black54`.
  final Color shadowColor;

  /// When specified, overrides the themes icon color for
  /// this `FloatingSearchBar`, for example to easily adjust
  /// the icon color for all [actions] and [leadingActions].
  final Color iconColor;

  /// The color that fills the available space when the
  /// `FloatingSearchBar` is opened.
  ///
  /// Typically a black-ish color.
  ///
  /// If not specified, defaults to `Colors.black26`.
  final Color backdropColor;

  /// The insets from the edges of its parent.
  ///
  /// This can be used to position the `FloatingSearchBar`.
  ///
  /// If not specifed, the `FloatingSearchBar` will try to
  /// position itself at the top offsetted by
  /// `MediaQuery.of(context).viewPadding.top` to avoid
  /// the status bar.
  final EdgeInsetsGeometry margins;

  /// The padding of the card.
  ///
  /// Only the horizontal values will be honored.
  final EdgeInsetsGeometry padding;

  /// The padding between [leadingActions], the input field and [actions],
  /// respectively.
  ///
  /// Only the horizontal values will be honored.
  final EdgeInsetsGeometry insets;

  /// The height of the card.
  ///
  /// If not specified, defaults to `48.0` pixels.
  final double height;

  /// The elevation of the card.
  ///
  /// See also:
  /// * [shadowColor] to adjust the color of the shadow.
  final double elevation;

  /// The max width of the `FloatingSearchBar`.
  ///
  /// By default the `FloatingSearchBar` will expand
  /// to fill all the available width. This value can
  /// be set to avoid this.
  final double maxWidth;

  /// The max width of the `FloatingSearchBar` when opened.
  ///
  /// This can be used, when the max width when opened should
  /// be different from the one specified by [maxWidth].
  ///
  /// When not specified, will use the value of [maxWidth].
  final double openMaxWidth;

  /// How the `FloatingSearchBar` should be aligned when the
  /// available width is bigger than the width specified by [maxWidth].
  ///
  /// When not specified, defaults to `0.0` which centers
  /// the `FloatingSearchBar`.
  final double axisAlignment;

  /// How the `FloatingSearchBar` should be aligned when the
  /// available width is bigger than the width specified by [openMaxWidth].
  ///
  /// When not specified, will use the value of [axisAlignment].
  final double openAxisAlignment;

  /// The border of the card.
  final BorderSide border;

  /// The [BorderRadius] of the card.
  ///
  /// When not specified, defaults to `BorderRadius.circular(4)`.
  final BorderRadius borderRadius;

  /// The [TextStyle] for the hint in the [TextField].
  final TextStyle hintStyle;

  /// The [TextStyle] for the input of the [TextField].
  final TextStyle queryStyle;

  // * --- Utility --- *
  /// {@template floating_search_bar.clearQueryOnClose}
  /// Whether the current query should be cleared when
  /// the `FloatingSearchBar` was closed.
  ///
  /// When not specifed, defaults to `true`.
  /// {@endtemplate}
  final bool clearQueryOnClose;

  /// {@template floating_search_bar.automaticallyImplyDrawerHamburger}
  /// Whether a hamburger menu should be shown when
  /// there is a [Scaffold] with a [Drawer] in the widget
  /// tree.
  ///
  /// When not specified, defaults to `true`.
  /// {@endtemplate}
  final bool automaticallyImplyDrawerHamburger;

  /// {@template floating_search_bar.automaticallyImplyBackButton}
  /// Whether to automatically display a back button if the enclosing route
  /// can be popped.
  ///
  /// When not specified, defaults to `true`.
  /// {@endtemplate}
  final bool automaticallyImplyBackButton;

  /// Whether the `FloatingSearchBar` should be closed when
  /// the backdrop was tapped.
  ///
  /// When not specified, defaults to `true`.
  final bool closeOnBackdropTap;

  /// {@template floating_search_bar.progress}
  /// The progress of the [LinearProgressIndicator] inside the bar.
  ///
  /// When set to a `double` between [0..1], will show
  /// show a determined [LinearProgressIndicator].
  ///
  /// When set to `true`, the `FloatingSearchBar` will
  /// show an indetermined [LinearProgressIndicator].
  ///
  /// When `null` or `false`, will hide the [LinearProgressIndicator].
  /// {@endtemplate}
  final dynamic progress;

  /// {@template floating_search_bar.transitionDuration}
  /// The duration of the animation between opened and closed
  /// state.
  /// {@endtemplate}
  final Duration transitionDuration;

  /// {@template floating_search_bar.transitionCurve}
  /// The curve for the animation between opened and closed
  /// state.
  /// {@endtemplate}
  final Curve transitionCurve;

  /// {@template floating_search_bar.debounceDelay}
  /// The delay between the time the user stopped typing
  /// and the invocation of the [onQueryChanged] callback.
  ///
  /// This is useful for example if you want to avoid doing
  /// expensive tasks, such as making a network call, for every
  /// single character.
  /// {@endtemplate}
  final Duration debounceDelay;

  /// {@template floating_search_bar.title}
  /// A widget that is shown in place of the [TextField] when the
  /// `FloatingSearchBar` is closed.
  /// {@endtemplate}
  final Widget title;

  /// {@template floating_search_bar.hint}
  /// The text value of the hint of the [TextField].
  /// {@endtemplate}
  final String hint;

  /// {@template floating_search_bar.actions}
  /// A list of widgets displayed in a row after the [TextField].
  ///
  /// Consider using [FloatingSearchBarAction]s for more advanced
  /// actions that can interact with the `FloatingSearchBar`.
  ///
  /// In LTR languages, they will be displayed to the left of
  /// the [TextField].
  /// {@endtemplate}
  final List<Widget> actions;

  /// {@template floating_search_bar.leadingActions}
  /// A list of widgets displayed in a row before the [TextField].
  ///
  /// Consider using [FloatingSearchBarAction]s for more advanced
  /// actions that can interact with the `FloatingSearchBar`.
  ///
  /// In LTR languages, they will be displayed to the right of
  /// the [TextField].
  /// {@endtemplate}
  final List<Widget> leadingActions;

  /// {@template floating_search_bar.onQueryChanged}
  /// A callback that gets invoked when the input of
  /// the query inside the [TextField] changed.
  ///
  /// See also:
  ///   * [debounceDelay] to delay the invocation of the callback
  ///   until the user stopped typing.
  /// {@endtemplate}
  final OnQueryChangedCallback onQueryChanged;

  /// {@template floating_search_bar.onSubmitted}
  /// A callback that gets invoked when the user submitted
  /// their query (e.g. hit the search button).
  /// {@endtemplate}
  final OnQueryChangedCallback onSubmitted;

  /// {@template floating_search_bar.onFocusChanged}
  /// A callback that gets invoked when the `FloatingSearchBar`
  /// receives or looses focus.
  /// {@endtemplate}
  final OnFocusChangedCallback onFocusChanged;

  /// The transition to be used for animating between closed
  /// and opened state.
  ///
  /// See also:
  ///  * [FloatingSearchBarTransition], which is the base class for all transitions
  ///    and can be used to create your own custom transition.
  ///  * [ExpandingFloatingSearchBarTransition], which expands to eventually fill
  ///    all of its available space, similar to the ones in Gmail or Google Maps.
  ///  * [CircularFloatingSearchBarTransition], which clips its child in an
  ///    expanding circle while animating.
  ///  * [SlideFadeFloatingSearchBarTransition], which fades and translate its
  ///    child.
  final FloatingSearchBarTransition transition;

  final bool fadeOffscreen;

  /// The builder for the body of this `FloatingSearchBar`.
  ///
  /// Usually, a list of items. Note that unless [isScrollControlled]
  /// is set to `true`, the body of a `FloatingSearchBar` must not
  /// have an unbounded height meaning that `shrinkWrap` should be set
  /// to `true` on all [Scrollable]s.
  final FloatingSearchBarBuilder builder;

  /// {@template floating_search_bar.controller}
  /// The controller for this `FloatingSearchBar` which can be used
  /// to programatically open, close, show or hide the `FloatingSearchBar`.
  /// {@endtemplate}
  final FloatingSearchBarController controller;

  /// {@template floating_search_bar.textInputAction}
  /// The [TextInputAction] to be used by the [TextField]
  /// of this `FloatingSearchBar`.
  /// {@endtemplate}
  final TextInputAction textInputAction;

  /// {@template floating_search_bar.textInputType}
  /// The [TextInputType] of the [TextField]
  /// of this `FloatingSearchBar`.
  /// {@endtemplate}
  final TextInputType textInputType;

  /// {@template floating_search_bar.autocorrect}
  /// Enable or disable autocorrection of the [TextField] of
  /// this `FloatingSearchBar`.
  /// {@endtemplate}
  final bool autocorrect;

  /// {@template floating_search_bar.toolbarOptions}
  /// The [ToolbarOptions] of the [TextField] of
  /// this `FloatingSearchBar`.
  /// {@endtemplate}
  final ToolbarOptions toolbarOptions;

  /// Hides the `FloatingSearchBar` intially for the specified
  /// duration and then translates it from the top to its position.
  ///
  /// This can be used as a simple enrance animation.
  final Duration showAfter;

  // * --- Scrolling --- *
  /// Whether the body of this `FloatingSearchBar` is using its
  /// own [Scrollable].
  ///
  /// This will allow the body of the `FloatingSearchBar` to have an
  /// unbounded height.
  ///
  ///
  /// to dismiss itself when tapped below the height of child inside the
  /// [Scrollable], when the child is smaller than the avaialble height.
  final bool isScrollControlled;

  /// The [ScrollPhysics] of the [SingleChildScrollView] for the body of
  /// this `FloatingSearchBar`.
  final ScrollPhysics physics;

  /// The [ScrollController] of the [SingleChildScrollView] for the body of
  /// this `FloatingSearchBar`.
  final ScrollController scrollController;

  /// The [EdgeInsets] of the [SingleChildScrollView] holding the expandable body of
  /// this `FloatingSearchBar`.
  final EdgeInsets scrollPadding;
  const FloatingSearchBar({
    Key key,
    Duration implicitDuration = const Duration(milliseconds: 600),
    Curve implicitCurve = Curves.linear,
    this.body,
    this.accentColor,
    this.backgroundColor,
    this.shadowColor = Colors.black87,
    this.iconColor,
    this.backdropColor,
    this.margins,
    this.padding,
    this.insets,
    this.height = 48.0,
    this.elevation = 4.0,
    this.maxWidth,
    this.openMaxWidth,
    this.axisAlignment = 0.0,
    this.openAxisAlignment,
    this.border,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.hintStyle,
    this.queryStyle,
    this.clearQueryOnClose = true,
    this.automaticallyImplyDrawerHamburger = true,
    this.automaticallyImplyBackButton = true,
    this.closeOnBackdropTap = true,
    this.progress = false,
    this.transitionDuration = const Duration(milliseconds: 500),
    this.transitionCurve = Curves.ease,
    this.debounceDelay = Duration.zero,
    this.title,
    this.hint = 'Search...',
    this.actions,
    this.leadingActions,
    this.onQueryChanged,
    this.onSubmitted,
    this.onFocusChanged,
    this.transition,
    this.fadeOffscreen,
    @required this.builder,
    this.controller,
    this.textInputAction = TextInputAction.search,
    this.textInputType,
    this.autocorrect = true,
    this.toolbarOptions,
    this.showAfter,
    this.isScrollControlled = true,
    this.physics,
    this.scrollController,
    this.scrollPadding = const EdgeInsets.symmetric(vertical: 16),
  })  : assert(builder != null),
        super(key, implicitDuration, implicitCurve);

  @override
  FloatingSearchBarState createState() => FloatingSearchBarState();

  static FloatingSearchBarState of(BuildContext context) {
    return context.findAncestorStateOfType<FloatingSearchBarState>();
  }
}

class FloatingSearchBarState extends ImplicitlyAnimatedWidgetState<
    FloatingSearchBarStyle, FloatingSearchBar> {
  final GlobalKey<FloatingSearchAppBarState> barKey = GlobalKey();
  FloatingSearchAppBarState get barState => barKey.currentState;

  AnimationController _controller;
  CurvedAnimation _animation;
  CurvedAnimation get animation => _animation;

  AnimationController _translateController;
  CurvedAnimation _translateAnimation;

  AnimationController _translateOpacityController;
  Animation<double> _translateOpacityAnimation;

  FloatingSearchBarTransition transition;
  ScrollController _scrollController;

  dynamic get progress => widget.progress;

  FloatingSearchBarStyle get style => value;
  double get height => style.height;
  double get elevation => style.elevation;
  double get maxWidth => style.maxWidth;
  double get openMaxWidth => style.openMaxWidth;
  double get axisAlignment => style.axisAlignment;
  double get openAxisAlignment => style.openAxisAlignment;
  Color get backgroundColor => style.backgroundColor;
  Color get backdropColor => style.backdropColor;

  BorderRadius get borderRadius => style.borderRadius;

  EdgeInsetsGeometry get margins => style.margins;
  EdgeInsetsGeometry get padding => style.padding;
  EdgeInsetsGeometry get insets => style.insets;

  Text get title => widget.title;
  String get hint => widget.hint?.toString() ?? '';

  Curve get curve => widget.transitionCurve;
  Duration get duration => widget.transitionDuration;
  Duration get queryCallbackDelay => widget.debounceDelay;

  bool get isOpen => barState?.isOpen ?? false;
  set isOpen(bool value) {
    if (value != isOpen) barState?.isOpen = value;
    value ? _controller.forward() : _controller.reverse();
  }

  bool get isVisible => _translateController.isDismissed;
  set isVisible(bool value) {
    if (value == isVisible) return;

    // Only hide the bar when it is not opened.
    if (!isOpen) {
      value ? _translateController.reverse() : _translateController.forward();
    }
  }

  final ValueNotifier<int> _barRebuilder = ValueNotifier(0);
  void rebuild() => _barRebuilder.value++;

  double _offset = 0.0;
  double get offset => _offset;

  double get v => _animation.value;
  bool get isAnimating => _controller.isAnimating;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          _onClosed();
        }
      });

    _animation = CurvedAnimation(parent: _controller, curve: curve);

    _translateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _translateAnimation = CurvedAnimation(
      parent: _translateController,
      curve: Curves.easeInOut,
    );

    _translateOpacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 0),
    );

    _translateOpacityAnimation = CurvedAnimation(parent: _translateController, curve: Curves.fastOutSlowIn);

    transition = widget.transition ?? SlideFadeFloatingSearchBarTransition();

    _scrollController = widget.scrollController ?? ScrollController();

    if (widget.showAfter != null) {
      _translateController.value = 1.0;
      Future.delayed(widget.showAfter, show);
    }

    _assignController();
  }

  @override
  void didUpdateWidget(FloatingSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (curve != oldWidget.transitionCurve) {
      _animation = CurvedAnimation(parent: _controller, curve: curve);
    }

    if (duration != oldWidget.transitionDuration) {
      _controller.duration = duration;
    }

    if (widget.transition != null && widget.transition != transition) {
      transition = widget.transition;
    }

    if (widget.scrollController != null &&
        widget.scrollController != _scrollController) {
      _scrollController = widget.scrollController;
    }

    _assignController();
  }

  void _assignController() => widget.controller?._searchBarState = this;

  void show() => isVisible = true;
  void hide() => isVisible = false;

  void open() => isOpen = true;
  void close() => isOpen = false;

  Future<bool> _onPop() async {
    if (isOpen) {
      close();
      return false;
    }

    return true;
  }

  void _onClosed() {
    _offset = 0.0;
    _scrollController.jumpTo(0.0);
  }

  EdgeInsets _resolve(EdgeInsetsGeometry insets) =>
      insets?.resolve(Directionality.of(context)) ?? EdgeInsets.zero;

  bool _onBuilderScroll(ScrollNotification notification) {
    _offset = notification.metrics.pixels;
    transition.onBodyScrolled();
    return false;
  }

  double _lastPixel = 0.0;

  void _setTranslateCurve(Curve curve) {
    if (_translateAnimation.curve != curve) {
      setState(() {
        _translateAnimation = CurvedAnimation(
          parent: _translateController,
          curve: curve,
        );
      });
    }
  }

  bool _onBodyScroll(FloatingSearchBarScrollNotification notification) {
    if (_controller.isDismissed) {
      final pixel = notification.metrics.pixels;
      final didReleasePointer = pixel == _lastPixel;

      if (didReleasePointer) {
        _setTranslateCurve(Curves.easeInOutCubic);
        final hide = pixel > 0.0 && _translateController.value > 0.5;
        hide ? _translateController.forward() : _translateController.reverse();
      } else {
        _setTranslateCurve(Curves.linear);

        final delta = pixel - _lastPixel;

        _translateController.value += delta / (height + _resolve(margins).top);
        _lastPixel = pixel;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    transition.searchBar = this;

    final searchBar = SizedBox.expand(
      child: WillPopScope(
        onWillPop: _onPop,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onBuilderScroll,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return Stack(
                children: <Widget>[
                  _buildBackdrop(),
                  _buildSearchBar(),
                ],
              );
            },
          ),
        ),
      ),
    );

    if (widget.body != null) {
      final body = NotificationListener<FloatingSearchBarScrollNotification>(
        onNotification: _onBodyScroll,
        child: widget.body,
      );

      return Stack(
        fit: StackFit.expand,
        children: [
          body,
          searchBar,
        ],
      );
    } else {
      return searchBar;
    }
  }

  Widget _buildSearchBar() {
    final isInside = transition.isBodyInsideSearchBar;
    final boxConstraints =
        BoxConstraints(maxWidth: transition.lerpMaxWidth() ?? double.infinity);

    final bar = ValueListenableBuilder(
      valueListenable: _barRebuilder,
      builder: (context, __, _) {
        final padding = _resolve(transition.lerpPadding());
        final borderRadius = transition.lerpBorderRadius();

        final container = AnimatedBuilder(
          animation: _translateController,
          builder: (context, _) => Opacity(
            opacity: 1 - _translateOpacityAnimation.value,
            child: Semantics(
              hidden: !isVisible,
              focusable: true,
              focused: isOpen,
              child: Padding(
                padding: transition.lerpMargin(),
                child: Material(
                  elevation: transition.lerpElevation(),
                  shadowColor: style.shadowColor,
                  borderRadius: borderRadius,
                  child: Container(
                    height: transition.lerpHeight(),
                    padding:
                        EdgeInsets.only(top: padding.top, bottom: padding.bottom),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: transition.lerpBackgroundColor(),
                      border: style.border != null
                          ? Border.fromBorderSide(style.border)
                          : null,
                      borderRadius: borderRadius,
                    ),
                    constraints: boxConstraints,
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: _buildInnerBar(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        return SlideTransition(
          position: Tween(
            begin: Offset.zero,
            end: const Offset(0.0, -1.0),
          ).animate(_translateAnimation),
          child: container,
        );
      },
    );

    if (isInside) return bar;

    return AnimatedAlign(
      duration: isAnimating ? duration : Duration.zero,
      curve: widget.transitionCurve,
      alignment: Alignment(isOpen ? openAxisAlignment : axisAlignment, 0.0),
      child: Column(
        children: <Widget>[
          bar,
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerBar() {
    final textField = FloatingSearchAppBar(
      body: null,
      key: barKey,
      height: 1000,
      elevation: 0.0,
      controller: widget.controller,
      color: transition.lerpBackgroundColor(),
      onFocusChanged: (isFocused) {
        isOpen = isFocused;
        widget.onFocusChanged?.call(isFocused);
      },
      implicitDuration: widget.duration,
      implicitCurve: widget.curve,
      title: widget.title,
      actions: widget.actions,
      leadingActions: widget.leadingActions,
      autocorrect: widget.autocorrect,
      clearQueryOnClose: widget.clearQueryOnClose,
      debounceDelay: widget.debounceDelay,
      hint: widget.hint,
      onQueryChanged: widget.onQueryChanged,
      onSubmitted: widget.onSubmitted,
      progress: widget.progress,
      automaticallyImplyDrawerHamburger:
          widget.automaticallyImplyDrawerHamburger,
      automaticallyImplyBackButton: widget.automaticallyImplyBackButton,
      toolbarOptions: widget.toolbarOptions,
      transitionDuration: widget.transitionDuration,
      transitionCurve: widget.transitionCurve,
      textInputAction: widget.textInputAction,
      textInputType: widget.textInputType,
      accentColor: widget.accentColor,
      hintStyle: widget.hintStyle,
      iconColor: widget.iconColor,
      insets: style.insets,
      padding: style.padding,
      titleStyle: widget.queryStyle,
      shadowColor: style.shadowColor,
    );

    final padding = _resolve(transition.lerpPadding());

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          if (transition.isBodyInsideSearchBar && v > 0.0)
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(top: height),
                child: _buildBody(),
              ),
            ),
          Material(
            elevation: transition.lerpInnerElevation(),
            shadowColor: style.shadowColor,
            child: Container(
              height: height,
              color: transition.lerpBackgroundColor(),
              alignment: Alignment.topCenter,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    constraints: maxWidth != null
                        ? BoxConstraints(
                            maxWidth: transition.lerpInnerMaxWidth(),
                          )
                        : null,
                    padding: EdgeInsets.only(
                        left: padding.left, right: padding.right),
                    child: textField,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: transition.buildDivider(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final body = transition.buildTransition(
      FloatingSearchBarDismissable(
        controller: _scrollController,
        padding: widget.scrollPadding,
        physics: widget.physics,
        child: widget.builder(context, animation),
      ),
    );

    return IgnorePointer(
      ignoring: widget.isScrollControlled && v < 1.0,
      child: Container(
        constraints: maxWidth != null
            ? BoxConstraints(
                maxWidth: transition.lerpMaxWidth() +
                    transition.lerpMargin().horizontal,
              )
            : null,
        child: body,
      ),
    );
  }

  Widget _buildBackdrop() {
    if (v == 0.0) return const SizedBox(height: 0);

    return FadeTransition(
      opacity: animation,
      child: GestureDetector(
        onTap: () {
          if (widget.closeOnBackdropTap) {
            close();
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: backdropColor,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _barRebuilder.dispose();
    _controller.dispose();

    widget.controller?._searchBarState = null;

    if (widget.scrollController == null) {
      _scrollController?.dispose();
    }

    super.dispose();
  }

  // * Implicit stuff

  @override
  FloatingSearchBarStyle get newValue {
    final theme = Theme.of(context);
    final direction = Directionality.of(context);

    return FloatingSearchBarStyle(
      height: widget.height ?? 48.0,
      elevation: widget.elevation ?? 4.0,
      maxWidth: widget.maxWidth,
      openMaxWidth: widget.openMaxWidth ?? widget.maxWidth,
      axisAlignment: widget.axisAlignment ?? 0.0,
      openAxisAlignment:
          widget.openAxisAlignment ?? widget.axisAlignment ?? 0.0,
      backgroundColor: widget.backgroundColor ?? theme.cardColor,
      shadowColor: widget.shadowColor ?? Colors.black45,
      backdropColor: widget.backdropColor ??
          widget.transition.backdropColor ??
          Colors.black26,
      border: widget.border ?? BorderSide.none,
      borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
      margins: widget.margins ??
          EdgeInsets.fromLTRB(
                  8, MediaQuery.of(context).viewPadding.top + 6, 8, 0)
              .resolve(direction),
      padding: widget.padding,
      insets: widget.insets,
    );
  }

  @override
  FloatingSearchBarStyle lerp(
          FloatingSearchBarStyle a, FloatingSearchBarStyle b, double t) =>
      a.scaleTo(b, t);
}

/// A controller for a [FloatingSearchBar].
class FloatingSearchBarController {
  /// Creates a controller for a [FloatingSearchBar].
  FloatingSearchBarController();

  FloatingSearchAppBarState _appBarState;
  FloatingSearchBarState _searchBarState;

  /// Opens/Expands the [FloatingSearchBar].
  void open() => _appBarState?.open();

  /// Closes/Collapses the [FloatingSearchBar].
  void close() => _appBarState?.close();

  /// Visually reveals the [FloatingSearchBar] when
  /// it was previously hidden via [hide].
  void show() => _searchBarState?.show();

  /// Visually hides the [FloatingSearchBar].
  void hide() => _searchBarState?.hide();

  /// Sets the query of the input of the [FloatingSearchBar].
  set query(String query) {
    if (_appBarState == null) {
      postFrame(() => _appBarState?.query = query);
    } else {
      _appBarState?.query = query;
    }
  }

  /// The current query of the [FloatingSearchBar].
  String get query => _appBarState?.query;

  /// Cleares the current query.
  void clear() => _appBarState?.clear();

  /// Whether the [FloatingSearchBar] is currently
  /// opened/expanded.
  bool get isOpen => _appBarState?.isOpen == true;

  /// Whether the [FloatingSearchBar] is currently
  /// closed/collapsed.
  bool get isClosed => _appBarState?.isOpen == false;

  /// Whether the [FloatingSearchBar] is currently
  /// not hidden.
  bool get isVisible => _searchBarState?.isVisible == true;

  /// Whether the [FloatingSearchBar] is currently
  /// not visible.
  bool get isHidden => _searchBarState?.isVisible == false;

  /// Disposes this controller.
  void dispose() {
    _searchBarState = null;
    _appBarState = null;
  }
}
