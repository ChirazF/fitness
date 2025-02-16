part of 'onboarding_bloc.dart';

abstract class OnboardingEvent {}

class PageSwipedEvent extends OnboardingEvent {
  final int index;
  PageSwipedEvent({required this.index});
}

class PageChangedEvent extends OnboardingEvent {}
