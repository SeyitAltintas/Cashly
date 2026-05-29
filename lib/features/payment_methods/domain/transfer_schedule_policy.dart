class TransferSchedulePolicy {
  const TransferSchedulePolicy._();

  static bool isScheduled({required DateTime selectedDate, DateTime? now}) {
    final reference = now ?? DateTime.now();
    final referenceMinute = DateTime(
      reference.year,
      reference.month,
      reference.day,
      reference.hour,
      reference.minute,
    );
    final selectedMinute = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedDate.hour,
      selectedDate.minute,
    );

    return selectedMinute.isAfter(referenceMinute);
  }

  static bool isDue({required DateTime selectedDate, DateTime? now}) {
    return !isScheduled(selectedDate: selectedDate, now: now);
  }
}
