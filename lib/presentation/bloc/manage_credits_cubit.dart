import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_genie/services/repository/firebase_db_repository.dart';

part 'manage_credits_state.dart';

class ManageCreditsCubit extends Cubit<ManageCreditsState> {
  ManageCreditsCubit(this.firebaseDBRepository) : super(ManageCreditsInitial());
  final FirebaseDBRepository firebaseDBRepository;

  void addCredits(Map<String, dynamic> userDetails) async {
    emit(ManageCreditsLoading());
    try {
      await firebaseDBRepository.addCreativeCredits();
      emit(const AddCreditsLoaded());
    } catch (e) {
      emit(ManageCreditsError(message: e.toString()));
    }
  }

  void deductCredits(String credits) async {
    emit(ManageCreditsLoading());
    try {
      await firebaseDBRepository.deductCreativeCredits(credits);
      emit(const DeductCreditsLoaded());
    } catch (e) {
      emit(ManageCreditsError(message: e.toString()));
    }
  }

  void getCreditDetails() async {
    emit(ManageCreditsLoading());
    try {
      final credits = await firebaseDBRepository.getCreativeCredits();
      emit(GetCreditDetailsLoaded(credits: credits));
    } catch (e) {
      emit(ManageCreditsError(message: e.toString()));
    }
  }
}
