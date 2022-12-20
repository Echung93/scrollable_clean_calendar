import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/models/day_values_model.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:scrollable_clean_calendar/utils/extensions.dart';

class DaysWidget extends StatelessWidget {
  final CleanCalendarController cleanCalendarController;
  final DateTime month;
  final double calendarCrossAxisSpacing;
  final double calendarMainAxisSpacing;
  final Layout? layout;
  final Widget Function(
      BuildContext context,
      DayValues values,
      )? dayBuilder;
  final Color? selectedBackgroundColor;
  final Color? backgroundColor;
  final Color? selectedBackgroundColorBetween;
  final Color? disableBackgroundColor;
  final Color? dayDisableColor;
  final double radius;
  final TextStyle? textStyle;
  final List<dynamic>? plan;

  const DaysWidget({
    Key? key,
    required this.month,
    required this.cleanCalendarController,
    required this.calendarCrossAxisSpacing,
    required this.calendarMainAxisSpacing,
    required this.layout,
    required this.dayBuilder,
    required this.selectedBackgroundColor,
    required this.backgroundColor,
    required this.selectedBackgroundColorBetween,
    required this.disableBackgroundColor,
    required this.dayDisableColor,
    required this.radius,
    required this.textStyle,
    this.plan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Start weekday - Days per week - The first weekday of this month
    // 7 - 7 - 1 = -1 = 1
    // 6 - 7 - 1 = -2 = 2

    // What it means? The first weekday does not change, but the start weekday have changed,
    // so in the layout we need to change where the calendar first day is going to start.
    int monthPositionStartDay = (cleanCalendarController.weekdayStart -
        DateTime.daysPerWeek -
        DateTime(month.year, month.month).weekday)
        .abs();
    monthPositionStartDay = monthPositionStartDay > DateTime.daysPerWeek
        ? monthPositionStartDay - DateTime.daysPerWeek
        : monthPositionStartDay;

    final start = monthPositionStartDay == 7 ? 0 : monthPositionStartDay;

    // If the monthPositionStartDay is equal to 7, then in this layout logic will cause a trouble, beacause it will
    // have a line in blank and in this case 7 is the same as 0.

    return GridView.count(
      crossAxisCount: DateTime.daysPerWeek,
      physics: const NeverScrollableScrollPhysics(),
      addRepaintBoundaries: false,
      padding: EdgeInsets.zero,
      crossAxisSpacing: calendarCrossAxisSpacing,
      mainAxisSpacing: calendarMainAxisSpacing,
      shrinkWrap: true,
      children: List.generate(
          DateTime(month.year, month.month + 1, 0).day + start, (index) {
        if (index < start) return const SizedBox.shrink();
        final day = DateTime(month.year, month.month, (index + 1 - start));
        final text = (index + 1 - start).toString();

        bool isSelected = false;
        bool anotherDay = false;

        if (cleanCalendarController.rangeMinDate != null) {
          if (cleanCalendarController.rangeMinDate != null &&
              cleanCalendarController.rangeMaxDate != null) {
            isSelected = day
                .isSameDayOrAfter(cleanCalendarController.rangeMinDate!) &&
                day.isSameDayOrBefore(cleanCalendarController.rangeMaxDate!);
          } else {
            isSelected =
                day.isAtSameMomentAs(cleanCalendarController.rangeMinDate!);
          }
        }

        if (plan!.isNotEmpty) {
          if (DateTime.now().isSameDayOrBefore(day)) {
            for (int i = 0; i < plan!.length; i++) {
              String? start = plan![i].planStartDate;
              String? end = plan![i].planEndDate;

              anotherDay = day.isSameDayOrAfter(DateTime.parse(start!)) &&
                  day.isSameDayOrBefore(DateTime.parse(end!));

              if (anotherDay) {
                break;
              }
            }
          }
        }

        Widget widget;

        final dayValues = DayValues(
          day: day,
          isFirstDayOfWeek: day.weekday == cleanCalendarController.weekdayStart,
          isLastDayOfWeek: day.weekday == cleanCalendarController.weekdayEnd,
          isSelected: isSelected,
          maxDate: cleanCalendarController.maxDate,
          minDate: cleanCalendarController.minDate,
          text: text,
          selectedMaxDate: cleanCalendarController.rangeMaxDate,
          selectedMinDate: cleanCalendarController.rangeMinDate,
        );

        if (dayBuilder != null) {
          widget = dayBuilder!(context, dayValues);
        } else {
          widget = <Layout, Widget Function()>{
            Layout.DEFAULT: () => _pattern(context, dayValues),
            Layout.BEAUTY: () => _beauty(context, dayValues, anotherDay),
          }[layout]!();
        }

        return GestureDetector(
          onTap: () {
            if (day.isBefore(cleanCalendarController.minDate) &&
                !day.isSameDay(cleanCalendarController.minDate)) {
              if (cleanCalendarController.onPreviousMinDateTapped != null) {
                cleanCalendarController.onPreviousMinDateTapped!(day);
              }
            } else if (day.isAfter(cleanCalendarController.maxDate)) {
              if (cleanCalendarController.onAfterMaxDateTapped != null) {
                cleanCalendarController.onAfterMaxDateTapped!(day);
              }
            } else {
              if (!cleanCalendarController.readOnly) {
                cleanCalendarController.onDayClick(day);
              }
            }
          },
          child: widget,
        );
      }),
    );
  }

  Widget _pattern(BuildContext context, DayValues values) {
    Color bgColor = backgroundColor ?? Theme.of(context).colorScheme.surface;
    TextStyle txtStyle =
    (textStyle ?? Theme.of(context).textTheme.bodyText1)!.copyWith(
      color: backgroundColor != null
          ? backgroundColor!.computeLuminance() > .5
          ? Colors.black
          : Colors.white
          : Theme.of(context).colorScheme.onSurface,
    );

    if (values.isSelected) {
      if ((values.selectedMinDate != null &&
          values.day.isSameDay(values.selectedMinDate!)) ||
          (values.selectedMaxDate != null &&
              values.day.isSameDay(values.selectedMaxDate!))) {
        bgColor =
            selectedBackgroundColor ?? Theme.of(context).colorScheme.primary;
        txtStyle =
            (textStyle ?? Theme.of(context).textTheme.bodyText1)!.copyWith(
              color: selectedBackgroundColor != null
                  ? selectedBackgroundColor!.computeLuminance() > .5
                  ? Colors.black
                  : Colors.white
                  : Theme.of(context).colorScheme.onPrimary,
            );
      } else {
        bgColor = selectedBackgroundColorBetween ??
            Theme.of(context).colorScheme.primary.withOpacity(.3);
        txtStyle =
            (textStyle ?? Theme.of(context).textTheme.bodyText1)!.copyWith(
              color: selectedBackgroundColor != null &&
                  selectedBackgroundColor == selectedBackgroundColorBetween
                  ? selectedBackgroundColor!.computeLuminance() > .5
                  ? Colors.black
                  : Colors.white
                  : selectedBackgroundColor ??
                  Theme.of(context).colorScheme.primary,
            );
      }
    } else if (values.day.isSameDay(values.minDate)) {
      bgColor = Colors.transparent;
      txtStyle = (textStyle ?? Theme.of(context).textTheme.bodyText1)!.copyWith(
        color: selectedBackgroundColor ?? Theme.of(context).colorScheme.primary,
      );
    } else if (values.day.isBefore(values.minDate) ||
        values.day.isAfter(values.maxDate)) {
      bgColor = disableBackgroundColor ??
          Theme.of(context).colorScheme.surface.withOpacity(.4);
      txtStyle = (textStyle ?? Theme.of(context).textTheme.bodyText1)!.copyWith(
        color: dayDisableColor ??
            Theme.of(context).colorScheme.onSurface.withOpacity(.5),
        decoration: TextDecoration.lineThrough,
      );
    }

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        border: values.day.isSameDay(values.minDate)
            ? Border.all(
          color: selectedBackgroundColor ??
              Theme.of(context).colorScheme.primary,
          width: 2,
        )
            : null,
      ),
      child: Text(
        values.text,
        textAlign: TextAlign.center,
        style: txtStyle,
      ),
    );
  }

  Widget _beauty(BuildContext context, DayValues values, bool anotherDay) {
    BorderRadiusGeometry? borderRadius;
    Color bgColor = Colors.transparent;
    bool optionText = false;

    TextStyle txtStyle =
    (textStyle ?? Theme.of(context).textTheme.bodyText1)!.copyWith(
      color: getDayColor(values.day.weekday),
      fontWeight: values.isFirstDayOfWeek || values.isLastDayOfWeek
          ? FontWeight.bold
          : null,
    );
    borderRadius = BorderRadius.all(Radius.circular(radius));

    if(anotherDay) {
      bgColor = selectedBackgroundColorBetween ?? const Color(0xffaaaaaa);
      txtStyle =
          (textStyle ?? Theme.of(context).textTheme.bodyText1)!.copyWith(
            color:
            selectedBackgroundColor ?? Colors.white,
            fontWeight: values.isFirstDayOfWeek || values.isLastDayOfWeek
                ? FontWeight.bold
                : null,
          );

      for(int i = 0; i < plan!.length; i++) {
        optionText = values.day.isSameDay(DateTime.parse(plan![i].planStartDate!));
        if(optionText) {
          break;
        }
      }
    }

    if (values.isSelected) {
      if (values.isFirstDayOfWeek) {
      } else if (values.isLastDayOfWeek) {
      }

      if ((values.selectedMinDate != null &&
          values.day.isSameDay(values.selectedMinDate!)) ||
          (values.selectedMaxDate != null &&
              values.day.isSameDay(values.selectedMaxDate!))) {
        bgColor =
            selectedBackgroundColor ?? const Color(0xff5c5b75);
        txtStyle =
            (textStyle ?? Theme.of(context).textTheme.bodyText1)!.copyWith(
              color: selectedBackgroundColor != null
                  ? selectedBackgroundColor!.computeLuminance() > .5
                  ? Colors.black
                  : Colors.white
                  : Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            );

        if (values.selectedMinDate == values.selectedMaxDate) {
        } else if (values.selectedMinDate != null &&
            values.day.isSameDay(values.selectedMinDate!)) {
        } else if (values.selectedMaxDate != null &&
            values.day.isSameDay(values.selectedMaxDate!)) {
        }
      } else {
        bgColor = selectedBackgroundColorBetween ?? const Color(0xff5c5b75);
        txtStyle =
            (textStyle ?? Theme.of(context).textTheme.bodyText1)!.copyWith(
              color:
              selectedBackgroundColor ?? Colors.white,
              fontWeight: values.isFirstDayOfWeek || values.isLastDayOfWeek
                  ? FontWeight.bold
                  : null,
            );
      }
    } else if (values.day.isSameDay(values.minDate)) {
    } else if (values.day.isBefore(values.minDate) ||
        values.day.isAfter(values.maxDate)) {
      txtStyle = (textStyle ?? Theme.of(context).textTheme.bodyText1)!.copyWith(
        color: dayDisableColor ??
            Theme.of(context).colorScheme.onSurface.withOpacity(.5),
        decoration: TextDecoration.lineThrough,
        fontWeight: values.isFirstDayOfWeek || values.isLastDayOfWeek
            ? FontWeight.bold
            : null,
      );
    }

    return Container(
      margin: const EdgeInsets.all(9),
      child: Wrap(
        children: [
          Column(
            children: [
              Wrap(
                children: [
                  Container(
                    height: 33,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: borderRadius,
                    ),
                    child:Text(
                      values.text,
                      textAlign: TextAlign.center,
                      style: txtStyle,
                    ),
                  ),
                ],
              ),
              optionText ? Wrap(
                children: [
                  Text("other_schedule".tr, style: const TextStyle(fontSize: 10,), textAlign: TextAlign.center,),
                ],
              ) : Container(),
            ],
          ),
        ],
      ),
    );
  }

  Color getDayColor(int num) {
    Color color = Colors.black;

    if(num == 7) {
      color = Colors.red;
    } else if (num == 6) {
      color = Colors.blue;
    }

    return color;
  }
}
