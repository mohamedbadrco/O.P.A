import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './database_helper.dart'; // For Event type

// Event indicator colors (previously in main.dart, defined here for use)
const Color level1Green = Color.fromARGB(255, 74, 217, 104);
const Color level2Green = Color.fromRGBO(0, 137, 50, 1);

class MonthPageContent extends StatefulWidget {
  final DateTime monthToDisplay;
  final DateTime? selectedDate;
  final DateTime today;
  final Map<DateTime, List<Event>> events;
  final bool isFetchingAiSummary;
  final String? aiDaySummary;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onDateDoubleTap;
  final Function(DateTime) onShowDayEvents;
  final List<int> weekendDays;
  final Color? weekendColor;

  const MonthPageContent({
    super.key,
    required this.monthToDisplay,
    required this.selectedDate,
    required this.today,
    required this.events,
    required this.isFetchingAiSummary,
    required this.aiDaySummary,
    required this.onDateSelected,
    required this.onDateDoubleTap,
    required this.onShowDayEvents,
    required this.weekendDays,
    required this.weekendColor,
  });

  @override
  State<MonthPageContent> createState() => _MonthPageContentState();
}

class _MonthPageContentState extends State<MonthPageContent> {
  // Fraction of available height given to the month grid (0.0 - 1.0)
  double _topFraction = 0.6;

  // Whether the divider is actively being dragged (used to animate handle)
  bool _isDraggingDivider = false;

  Widget _buildSelectedDayEventSummary(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.selectedDate == null ||
        widget.selectedDate!.month != widget.monthToDisplay.month ||
        widget.selectedDate!.year != widget.monthToDisplay.year) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            widget.selectedDate == null
                ? "Select a day to see its AI summary."
                : "AI Summary will appear here for ${DateFormat.MMMM().format(widget.monthToDisplay)}.",
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "AI Summary for ${DateFormat.yMMMd().format(widget.selectedDate!)}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.open_in_new,
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.onBackground
                      : theme.colorScheme.primary,
                ),
                tooltip: "View Day Details",
                onPressed: () => widget.onShowDayEvents(widget.selectedDate!),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.isFetchingAiSummary
              ? const Center(child: CircularProgressIndicator())
              : widget.aiDaySummary != null && widget.aiDaySummary!.isNotEmpty
              ? SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    widget.aiDaySummary!,
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "No AI summary available for this day, or an error occurred.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  void _setTopFraction(double fraction) {
    setState(() {
      // Allow the special 1.0 (full month), 0.5 (split), and 0.2 (small month / large summary)
      _topFraction = fraction.clamp(0.0, 1.0);
    });
  }

  double _snapToClosest(double fraction) {
    // New fixed ratios: full month (1.0), split (0.5), small month (0.2)
    const List<double> options = [1.0, 0.5, 0.2];
    double best = options[0];
    double bestDiff = (fraction - best).abs();
    for (final f in options) {
      final d = (fraction - f).abs();
      if (d < bestDiff) {
        best = f;
        bestDiff = d;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prevNextMonthTextColor = theme.colorScheme.onSurface.withOpacity(
      0.38,
    );

    final firstDayOfMonth = DateTime(
      widget.monthToDisplay.year,
      widget.monthToDisplay.month,
      1,
    );
    final daysInMonth = DateTime(
      widget.monthToDisplay.year,
      widget.monthToDisplay.month + 1,
      0,
    ).day;
    final weekdayOffset = firstDayOfMonth.weekday % 7;
    List<Widget> dayWidgets = [];

    // Previous month's days
    final prevMonth = DateTime(
      widget.monthToDisplay.year,
      widget.monthToDisplay.month - 1,
    );
    final prevMonthDays = DateTime(prevMonth.year, prevMonth.month + 1, 0).day;
    for (int i = 0; i < weekdayOffset; i++) {
      final day = prevMonthDays - weekdayOffset + i + 1;
      dayWidgets.add(
        LayoutBuilder(
          builder: (context, constraints) {
            final boxSize = constraints.maxWidth;
            return Container(
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withOpacity(0.2),
                    width: 0.5,
                  ),
                  right: BorderSide(
                    color: theme.dividerColor.withOpacity(0),
                    width: 0.5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: boxSize * 0.35,
                    color: prevNextMonthTextColor,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Current month's days
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(
        widget.monthToDisplay.year,
        widget.monthToDisplay.month,
        day,
      );
      final isSelected =
          widget.selectedDate != null &&
          widget.selectedDate!.year == date.year &&
          widget.selectedDate!.month == date.month &&
          widget.selectedDate!.day == date.day;
      final isTodayDate =
          date.year == widget.today.year &&
          date.month == widget.today.month &&
          date.day == widget.today.day;
      final dayKey = DateTime(date.year, date.month, date.day);
      final int eventCount = widget.events[dayKey]?.length ?? 0;

      dayWidgets.add(
        LayoutBuilder(
          builder: (context, constraints) {
            final boxSize = constraints.maxWidth;

            Color? cellBackgroundColor;
            Color dayTextColor = theme.colorScheme.onSurface; // Default color
            FontWeight dayTextWeight = FontWeight.normal;
            BoxBorder? cellAllBorder;
            BorderSide topGridBorderSide = BorderSide(
              color: theme.dividerColor.withOpacity(0.2),
              width: 0.5,
            );
            BorderRadius? cellBorderRadius;
            Widget? eventIndicatorLine;

            TextStyle baseDayNumberTextStyle = theme.textTheme.bodySmall!
                .copyWith(fontSize: boxSize * 0.4 > 16 ? 16 : boxSize * 0.4);

            // Weekend coloring
            final isWeekend = widget.weekendDays.contains(date.weekday % 7);

            if (isTodayDate) {
              dayTextColor = level2Green; // Today's color
              dayTextWeight = FontWeight.w800;
            } else if (isWeekend) {
              dayTextColor =
                  widget.weekendColor ?? Colors.blue; // Weekend color
            }

            if (eventCount > 0) {
              Color lineColor = eventCount == 1 ? level1Green : level2Green;
              eventIndicatorLine = Container(
                width: boxSize * 0.6,
                height: 2.5,
                color: lineColor,
                margin: const EdgeInsets.only(top: 2.0),
              );
            }

            Color finalDayTextColor =
                dayTextColor; // Use the determined dayTextColor

            if (isSelected) {
              cellAllBorder = Border.all(
                color: theme.colorScheme.onSurface,
                width: 2,
              );
              cellBorderRadius = BorderRadius.circular(6.0);
              // dayTextColor is already set based on whether it is today, weekend or default.
              dayTextWeight = FontWeight.w800; // Selected day is always bold
            }

            final FontWeight finalDayTextWeight = isSelected || isTodayDate
                ? FontWeight.w800
                : dayTextWeight;

            Widget dayNumberText = Text(
              day.toString(),
              style: baseDayNumberTextStyle.copyWith(
                color: finalDayTextColor,
                fontWeight: finalDayTextWeight,
              ),
            );

            List<Widget> columnChildren = [dayNumberText];
            if (eventIndicatorLine != null) {
              columnChildren.add(eventIndicatorLine);
            }

            Widget dayContent = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: columnChildren,
            );

            Border? nonSelectedCellGridBorder;
            if (!isSelected) {
              nonSelectedCellGridBorder = Border(
                top: topGridBorderSide,
                right: BorderSide(
                  color: theme.dividerColor.withOpacity(0),
                  width: 0.5,
                ),
              );
            }

            return GestureDetector(
              onTap: () => widget.onDateSelected(date),
              onDoubleTap: () => widget.onDateDoubleTap(date),
              child: Container(
                width: boxSize,
                height: boxSize,
                decoration: isSelected
                    ? BoxDecoration(
                        color: cellBackgroundColor,
                        border: cellAllBorder,
                        borderRadius: cellBorderRadius,
                      )
                    : BoxDecoration(
                        color: cellBackgroundColor,
                        border: nonSelectedCellGridBorder,
                      ),
                child: Center(child: dayContent),
              ),
            );
          },
        ),
      );
    }

    // Next month's days
    int totalCells = weekdayOffset + daysInMonth;
    int nextDaysRequired = (totalCells <= 35)
        ? (35 - totalCells)
        : (42 - totalCells);

    for (int i = 1; i <= nextDaysRequired; i++) {
      dayWidgets.add(
        LayoutBuilder(
          builder: (context, constraints) {
            final boxSize = constraints.maxWidth;
            return Container(
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withOpacity(0.2),
                    width: 0.5,
                  ),
                  right: BorderSide(
                    color: theme.dividerColor.withOpacity(0),
                    width: 0.5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  i.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: boxSize * 0.35,
                    color: prevNextMonthTextColor,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight;
        const double dividerHeight = 28.0; // larger hit area
        const double minTopHeight = 120.0;
        const double minBottomHeight = 80.0;

        final numRows = ((weekdayOffset + daysInMonth) <= 35) ? 5 : 6;

        double topHeight = (_topFraction * totalHeight).clamp(
          minTopHeight,
          totalHeight - minBottomHeight - dividerHeight,
        );
        double bottomHeight = totalHeight - topHeight - dividerHeight;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          // Drag anywhere to resize: upward drag makes the summary (bottom) larger
          onVerticalDragUpdate: (details) {
            _setTopFraction(_topFraction + details.delta.dy / totalHeight);
          },
          onVerticalDragEnd: (details) {
            final vy = details.velocity.pixelsPerSecond.dy;
            if (vy < -700) {
              // fast upward swipe -> expand summary (minimize top)
              _setTopFraction(0.2);
            } else if (vy > 700) {
              // fast downward swipe -> expand month (maximize top)
              _setTopFraction(1.0);
            } else {
              // snap to nearest of the three fixed ratios
              _setTopFraction(_snapToClosest(_topFraction));
            }
          },
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                height: topHeight,
                child: GestureDetector(
                  onDoubleTap: () => _setTopFraction(1.0),
                  child: LayoutBuilder(
                    builder: (context, gridConstraints) {
                      final totalWidth = gridConstraints.maxWidth;

                      // If we're in the small-month (20%) state, show just one week as a horizontal row
                      final bool showWeekRow = _topFraction <= 0.21;
                      if (showWeekRow) {
                        final DateTime reference =
                            widget.selectedDate ?? widget.today;
                        final DateTime weekStart = DateTime(
                          reference.year,
                          reference.month,
                          reference.day - (reference.weekday % 7),
                        );
                        return Row(
                          children: List.generate(7, (i) {
                            final date = DateTime(
                              weekStart.year,
                              weekStart.month,
                              weekStart.day + i,
                            );
                            final isSelected =
                                widget.selectedDate != null &&
                                widget.selectedDate!.year == date.year &&
                                widget.selectedDate!.month == date.month &&
                                widget.selectedDate!.day == date.day;
                            final isTodayDate =
                                date.year == widget.today.year &&
                                date.month == widget.today.month &&
                                date.day == widget.today.day;

                            Color dayTextColor = Theme.of(
                              context,
                            ).colorScheme.onSurface;
                            if (isTodayDate) dayTextColor = level2Green;
                            final int eventCount =
                                widget
                                    .events[DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                    )]
                                    ?.length ??
                                0;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () => widget.onDateSelected(date),
                                child: Container(
                                  height: topHeight,
                                  decoration: isSelected
                                      ? BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        )
                                      : null,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          date.day.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: dayTextColor,
                                                fontWeight: isSelected
                                                    ? FontWeight.w800
                                                    : FontWeight.normal,
                                              ),
                                        ),
                                        if (eventCount > 0)
                                          Container(
                                            width: 18,
                                            height: 3,
                                            margin: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            color: eventCount == 1
                                                ? level1Green
                                                : level2Green,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      }

                      // Default: full month grid
                      final cellWidth = totalWidth / 7;
                      final cellHeight = topHeight / numRows;
                      final childAspect = cellWidth / cellHeight;

                      return GridView.count(
                        crossAxisCount: 7,
                        childAspectRatio: childAspect,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        children: dayWidgets,
                      );
                    },
                  ),
                ),
              ),

              // Divider / Drag handle
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragStart: (_) {
                  setState(() {
                    _isDraggingDivider = true;
                  });
                },
                onVerticalDragUpdate: (details) {
                  // keep consistent behavior when dragging the handle
                  _setTopFraction(
                    _topFraction + details.delta.dy / totalHeight,
                  );
                },
                onVerticalDragEnd: (_) {
                  setState(() {
                    _isDraggingDivider = false;
                  });
                  // Snap to closest after user finishes dragging the handle
                  _setTopFraction(_snapToClosest(_topFraction));
                },
                onVerticalDragCancel: () {
                  setState(() {
                    _isDraggingDivider = false;
                  });
                  _setTopFraction(_snapToClosest(_topFraction));
                },
                onDoubleTap: () => _setTopFraction(0.5),
                child: Container(
                  height: dividerHeight,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    width: _isDraggingDivider ? 56 : 48,
                    height: _isDraggingDivider ? 8 : 6,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: _isDraggingDivider
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.12),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),

              // Bottom summary area
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                height: bottomHeight,
                child: GestureDetector(
                  onDoubleTap: () => _setTopFraction(0.2),
                  child: _buildSelectedDayEventSummary(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
