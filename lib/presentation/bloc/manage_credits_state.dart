part of 'manage_credits_cubit.dart';

abstract class ManageCreditsState extends Equatable {
  const ManageCreditsState();

  @override
  List<Object> get props => [];
}

class ManageCreditsInitial extends ManageCreditsState {}

class ManageCreditsLoading extends ManageCreditsState {}

class AddCreditsLoaded extends ManageCreditsState {
  const AddCreditsLoaded();
}

class DeductCreditsLoaded extends ManageCreditsState {
  const DeductCreditsLoaded();
}

class GetCreditDetailsLoaded extends ManageCreditsState {
  const GetCreditDetailsLoaded({required this.credits});
  final String credits;
  @override
  List<Object> get props => [credits];
}

class ManageCreditsError extends ManageCreditsState {
  const ManageCreditsError({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}
