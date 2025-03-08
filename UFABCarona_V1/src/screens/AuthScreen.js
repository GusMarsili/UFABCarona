import React, { useState } from 'react';
import { 
  View, 
  Text, 
  TextInput, 
  TouchableOpacity, 
  StyleSheet, 
  Alert 
} from 'react-native';

// Importa a configuração do Firebase
import { auth } from '../scripts/firebaseConfig';

// Importações dos métodos do Firebase para autenticação
import { 
  createUserWithEmailAndPassword, 
  signInWithEmailAndPassword, 
  onAuthStateChanged 
} from 'firebase/auth';

export default function AuthScreen() {
  const [isRegistering, setIsRegistering] = useState(true);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  // Função para validação de e-mail institucional 
  // (Ineficiente e será substituída no futuro)
  const validateInstitutionalEmail = (email) => {
    const allowedDomain = "aluno.ufabc.edu.br";
    const emailDomain = email.substring(email.
                      lastIndexOf("@") + 1).toLowerCase();
    return emailDomain === allowedDomain;
  };

  // Função de cadastro
  const handleRegister = async () => {
    if (!validateInstitutionalEmail(email)) {
      Alert.alert('Erro', 'Utilize (aluno.ufabc.edu.br)');
      return;
    }

    try {
      const userCredential = await 
      createUserWithEmailAndPassword(auth, email, password);
      Alert.alert('Sucesso', 
        'Usuário cadastrado com sucesso!');
      // Limpa os campos
      setName('');
      setEmail('');
      setPassword('');
    } catch (error) {
      Alert.alert('Erro no cadastro', error.message);
    }
  };

  // Função de login
  const handleLogin = async () => {
    try {
      const userCredential = await 
      signInWithEmailAndPassword(auth, email, password);
      Alert.alert('Sucesso', 
        'Login realizado com sucesso!');
      // Limpa os campos
      setEmail('');
      setPassword('');
    } catch (error) {
      Alert.alert('Erro no login', error.message);
    }
  };

  // Exemplo de monitoramento do estado de autenticação
  onAuthStateChanged(auth, (user) => {
    if (user) {
      console.log('Usuário logado:', user.email);
    } else {
      console.log('Nenhum usuário logado');
    }
  });

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{isRegistering ? 
      'Cadastro' : 'Login'}</Text>

      {isRegistering && (
        <TextInput
          style={styles.input}
          placeholder="Nome completo"
          placeholderTextColor="#888"
          onChangeText={setName}
          value={name}
        />
      )}

      <TextInput
        style={styles.input}
        placeholder="E-mail institucional"
        placeholderTextColor="#888"
        onChangeText={setEmail}
        value={email}
        keyboardType="email-address"
        autoCapitalize="none"
      />

      <TextInput
        style={styles.input}
        placeholder="Senha"
        placeholderTextColor="#888"
        onChangeText={setPassword}
        value={password}
        secureTextEntry
      />

      <TouchableOpacity
        style={styles.button}
        onPress={isRegistering ? 
          handleRegister : handleLogin}
      >
        <Text style={styles.buttonText}>
          {isRegistering ? 'Cadastrar' : 'Entrar'}
        </Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={() => 
        setIsRegistering(!isRegistering)}>
        <Text style={styles.switchText}>
          {isRegistering
            ? 'Já possui uma conta? Faça login'
            : 'Não tem uma conta? Cadastre-se'}
        </Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    justifyContent: 'center',
    backgroundColor: '#ffffff'
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center'
  },
  input: {
    height: 50,
    borderColor: '#ccc',
    borderWidth: 1,
    borderRadius: 8,
    paddingHorizontal: 10,
    marginBottom: 15,
    color: '#000'
  },
  button: {
    backgroundColor: '#007bff',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center'
  },
  buttonText: {
    color: '#fff',
    fontSize: 18
  },
  switchText: {
    marginTop: 15,
    color: '#007bff',
    textAlign: 'center'
  },
});