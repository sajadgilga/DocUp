import 'package:bloc/bloc.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/repository/DoctorRepository.dart';
import 'package:docup/repository/PatientRepository.dart';
import 'package:docup/ui/start/RoleType.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class EntityBloc extends Bloc<EntityEvent, EntityState> {
  PatientRepository _patientRepository = PatientRepository();
  DoctorRepository _doctorRepository = DoctorRepository();

  @override
  get initialState => EntityLoaded(entity: Entity(type: RoleType.PATIENT));

  Stream<EntityState> _get() async* {
    Entity entity = state.entity;
    yield EntityLoading(entity: entity);
    try {
      UserEntity uEntity;
      if (state.entity.type == RoleType.PATIENT)
        uEntity = await _patientRepository.get();
      else if (state.entity.type == RoleType.DOCTOR)
        uEntity = await _doctorRepository.get();
      entity.mEntity = uEntity;

      if (entity.type == RoleType.PATIENT) {
        var panels = (entity.mEntity as PatientEntity).panels;
        if (panels.length > 0) add(PartnerEntitySet(id: panels[0].doctorId));
      } else if (state.entity.type == RoleType.DOCTOR) {
        var panels = (state.entity.mEntity as DoctorEntity).panels;
        if (panels.length > 0) add(PartnerEntitySet(id: panels[0].patientId));
      }

      yield EntityLoaded(entity: entity);
    } catch (e) {
      yield EntityError(entity: entity);
    }
  }

  Stream<EntityState> _getPartner(id) async* {
    Entity entity = state.entity;
    yield EntityPartnerLoading(entity: entity);
    try {
      UserEntity uEntity;
      if (state.entity.type == RoleType.PATIENT)
        uEntity = await _doctorRepository.getDoctor(id);
      else if (state.entity.type == RoleType.DOCTOR)
        uEntity = await _patientRepository.getPatient(id);
      entity.partnerEntity = uEntity;
      yield EntityLoaded(entity: entity);
    } catch (e) {
      yield EntityError(entity: entity);
    }
  }

  Stream<EntityState> _changeType(RoleType type) async* {
    Entity entity = state.entity;
    entity.type = type;
    yield EntityLoaded(entity: entity);
  }

  @override
  Stream<EntityState> mapEventToState(event) async* {
    if (event is EntityGet) {
      yield* _get();
    } else if (event is EntityUpdate) {
    } else if (event is EntityChangeType) {
      yield* _changeType(event.type);
    } else if (event is PartnerEntitySet) {
      yield* _getPartner(event.id);
    }
  }
}

//events
abstract class EntityEvent {}

class EntityGet extends EntityEvent {}

class EntityChangeType extends EntityEvent {
  final RoleType type;

  EntityChangeType({@required this.type});
}

class EntityUpdate extends EntityEvent {}

class PartnerEntitySet extends EntityEvent {
  final int id;

  PartnerEntitySet({@required this.id});
}

//states
abstract class EntityState extends Equatable {
  final Entity entity;

  EntityState({@required this.entity});

  @override
  List<Object> get props => [];
}

class EntityLoading extends EntityState {
  final Entity entity;

  EntityLoading({@required this.entity});

  @override
  List<Object> get props => [entity];
}

class EntityPartnerLoading extends EntityState {
  final Entity entity;

  EntityPartnerLoading({@required this.entity});

  @override
  List<Object> get props => [entity];
}

class EntityLoaded extends EntityState {
  final Entity entity;

  EntityLoaded({@required this.entity});

  @override
  List<Object> get props => [entity];
}

class EntityError extends EntityState {
  final Entity entity;

  EntityError({@required this.entity});

  @override
  List<Object> get props => [entity];
}
